import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:http/http.dart' as http;

import 'ai_service.dart';

class GroqAiService implements AiService {
  GroqAiService({
    required String apiKey,
    this.model = _defaultModel,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  static const _defaultModel = 'llama-3.3-70b-versatile';
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  final String _apiKey;
  final String model;
  final http.Client _client;

  @override
  bool get isLoaded => true;

  @override
  String? get loadedModelName => model;

  @override
  Future<bool> loadModel({String? modelPath, String? modelId}) async => true;

  @override
  Future<void> unloadModel() async {
    _client.close();
  }

  @override
  Stream<String> generateStream(List<AiMessage> messages) async* {
    dev.log('Groq: generateStream iniciado | modelo: $model');

    final body = jsonEncode({
      'model': model,
      'messages': messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList(),
      'stream': true,
      'temperature': 0.7,
      'max_tokens': 500,
    });

    final request = http.Request('POST', Uri.parse(_baseUrl))
      ..headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      })
      ..body = body;

    try {
      dev.log('Groq: enviando requisição POST para $_baseUrl');
      final response = await _client.send(request);
      dev.log('Groq: resposta HTTP ${response.statusCode}');

      if (response.statusCode == 401) {
        dev.log('Groq: erro 401 - chave inválida');
        yield 'Chave de API inválida. Verifique sua chave do Groq.';
        return;
      }
      if (response.statusCode == 429) {
        dev.log('Groq: erro 429 - rate limit');
        yield 'Limite de requisições excedido. Aguarde um momento.';
        return;
      }
      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        dev.log('Groq: HTTP ${response.statusCode} | body: $errorBody');
        yield 'Erro ao conectar: HTTP ${response.statusCode} | $errorBody';
        return;
      }

      var buffer = '';
      var tokenCount = 0;
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        while (buffer.contains('\n')) {
          final idx = buffer.indexOf('\n');
          final line = buffer.substring(0, idx);
          buffer = buffer.substring(idx + 1);

          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') {
            dev.log('Groq: streaming concluído | total tokens: $tokenCount');
            return;
          }

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            if (choices == null || choices.isEmpty) continue;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              tokenCount++;
              yield content;
            }
          } catch (_) {}
        }
      }
      dev.log('Groq: stream finalizado (sem [DONE]) | tokens: $tokenCount');
    } on SocketException {
      dev.log('Groq: SocketException - sem internet');
      yield 'Erro de conexão. Verifique sua internet.';
    } on HttpException {
      dev.log('Groq: HttpException - erro servidor');
      yield 'Erro no servidor. Tente novamente.';
    } catch (e) {
      dev.log('Groq: exceção - $e');
      final s = e.toString();
      if (s.contains('401') || s.contains('Unauthorized')) {
        yield 'Chave de API inválida. Verifique sua chave do Groq.';
      } else if (s.contains('429') || s.contains('Too Many Requests')) {
        yield 'Limite de requisições excedido. Aguarde um momento.';
      } else {
        yield 'Erro ao conectar: ${e.toString()}';
      }
    }
  }

  @override
  Future<String> generate(List<AiMessage> messages) async {
    final buffer = StringBuffer();
    await for (final token in generateStream(messages)) {
      buffer.write(token);
    }
    return buffer.toString();
  }
}
