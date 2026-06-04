import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'ai_service.dart';

class GroqAiService implements AiService {
  GroqAiService({required String apiKey, this.model = _defaultModel})
      : _apiKey = apiKey;

  static const _defaultModel = 'llama-3.1-8b-instant';
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  final String _apiKey;
  final String model;

  @override
  bool get isLoaded => true;

  @override
  String? get loadedModelName => model;

  @override
  Future<bool> loadModel({String? modelPath, String? modelId}) async => true;

  @override
  Future<void> unloadModel() async {}

  @override
  Stream<String> generateStream(List<AiMessage> messages) async* {
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
      final response = await http.Client().send(request);

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            if (choices == null || choices.isEmpty) continue;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {}
        }
      }
    } on SocketException {
      yield 'Erro de conexão. Verifique sua internet.';
    } on HttpException {
      yield 'Erro no servidor. Tente novamente.';
    } catch (e) {
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
