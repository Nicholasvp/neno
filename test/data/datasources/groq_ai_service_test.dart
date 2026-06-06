import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:neno/data/datasources/ai_service.dart';
import 'package:neno/data/datasources/groq_ai_service.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

http.StreamedResponse _okResponse(String body) {
  final stream = http.ByteStream.fromBytes(utf8.encode(body));
  return http.StreamedResponse(stream, 200);
}

void main() {
  late _MockHttpClient client;
  late GroqAiService service;

  const apiKey = 'gsk_test_key';
  final messages = [
    const AiMessage(role: 'system', content: 'You are a helpful assistant.'),
    const AiMessage(role: 'user', content: 'Hello'),
  ];

  setUpAll(() {
    registerFallbackValue(_FakeBaseRequest());
  });

  setUp(() {
    client = _MockHttpClient();
    service = GroqAiService(apiKey: apiKey, client: client);
  });

  group('constructor', () {
    test('isLoaded returns true', () {
      expect(service.isLoaded, true);
    });

    test('loadedModelName returns model name', () {
      expect(service.loadedModelName, 'llama-3.3-70b-versatile');
    });
  });

  group('generateStream', () {
    test('sends correct request headers and body', () async {
      when(() => client.send(any()))
          .thenAnswer((_) async => _okResponse('data: [DONE]\n'));

      await service.generateStream(messages).toList();

      final captured = verify(() => client.send(captureAny())).captured.single
          as http.Request;
      expect(captured.method, 'POST');
      expect(captured.url.toString(),
          'https://api.groq.com/openai/v1/chat/completions');
      expect(captured.headers['Authorization'], 'Bearer gsk_test_key');
      expect(captured.headers['Content-Type'], 'application/json');

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['model'], 'llama-3.3-70b-versatile');
      expect(body['stream'], true);
      expect(body['temperature'], 0.7);
      expect(body['max_tokens'], 500);

      final reqMessages = body['messages'] as List;
      expect(reqMessages.length, 2);
      expect(reqMessages[0]['role'], 'system');
      expect(reqMessages[0]['content'], 'You are a helpful assistant.');
      expect(reqMessages[1]['role'], 'user');
      expect(reqMessages[1]['content'], 'Hello');
    });

    test('yields tokens from SSE stream', () async {
      final sse = [
        'data: {"id":"1","choices":[{"index":0,"delta":{"role":"assistant","content":""},"finish_reason":null}]}\n',
        'data: {"id":"2","choices":[{"index":0,"delta":{"content":"Olá"},"finish_reason":null}]}\n',
        'data: {"id":"3","choices":[{"index":0,"delta":{"content":"!"},"finish_reason":null}]}\n',
        'data: [DONE]\n',
      ].join();
      when(() => client.send(any()))
          .thenAnswer((_) async => _okResponse(sse));

      final tokens = await service.generateStream(messages).toList();

      expect(tokens, ['Olá', '!']);
    });

    test('handles chunk split in the middle of a line', () async {
      final controller = StreamController<List<int>>();
      final stream = http.ByteStream(controller.stream);
      when(() => client.send(any()))
          .thenAnswer((_) async => http.StreamedResponse(stream, 200));

      final futures = [
        service.generateStream(messages).toList(),
      ];

      await Future.delayed(Duration.zero);
      controller.add(utf8.encode(
          'data: {"id":"1","choices":[{"index":0,"delta":{"content":"Olá"}}]}\n'));
      await Future.delayed(Duration.zero);
      controller.add(utf8.encode('data: [DONE]\n'));
      await Future.delayed(Duration.zero);
      await controller.close();

      final tokens = await futures.first;
      expect(tokens, ['Olá']);
    });

    test('handles chunk split mid-line with buffer', () async {
      final controller = StreamController<List<int>>();
      final stream = http.ByteStream(controller.stream);
      when(() => client.send(any()))
          .thenAnswer((_) async => http.StreamedResponse(stream, 200));

      final futures = [
        service.generateStream(messages).toList(),
      ];

      await Future.delayed(Duration.zero);
      controller.add(utf8.encode(
          'data: {"id":"1","choices":[{"index":0,"delta":{"co'));
      await Future.delayed(Duration.zero);
      controller.add(utf8.encode(
          'ntent":"Olá"}}]}\n'));
      await Future.delayed(Duration.zero);
      controller.add(utf8.encode('data: [DONE]\n'));
      await Future.delayed(Duration.zero);
      await controller.close();

      final tokens = await futures.first;
      expect(tokens, ['Olá']);
    });

    test('yields nothing when only empty delta tokens', () async {
      final sse = [
        'data: {"id":"1","choices":[{"index":0,"delta":{"role":"assistant","content":""},"finish_reason":null}]}\n',
        'data: {"id":"2","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}\n',
        'data: [DONE]\n',
      ].join();
      when(() => client.send(any()))
          .thenAnswer((_) async => _okResponse(sse));

      final tokens = await service.generateStream(messages).toList();

      expect(tokens, isEmpty);
    });

    test('returns error for 401 Unauthorized', () async {
      final stream = http.ByteStream.fromBytes(utf8.encode(''));
      when(() => client.send(any())).thenAnswer(
          (_) async => http.StreamedResponse(stream, 401));

      final tokens = await service.generateStream(messages).toList();

      expect(tokens, [
        'Chave de API inválida. Verifique sua chave do Groq.',
      ]);
    });

    test('returns error for 429 Too Many Requests', () async {
      final stream = http.ByteStream.fromBytes(utf8.encode(''));
      when(() => client.send(any())).thenAnswer(
          (_) async => http.StreamedResponse(stream, 429));

      final tokens = await service.generateStream(messages).toList();

      expect(tokens, [
        'Limite de requisições excedido. Aguarde um momento.',
      ]);
    });

    test('returns error for unexpected status code', () async {
      final stream = http.ByteStream.fromBytes(utf8.encode(''));
      when(() => client.send(any())).thenAnswer(
          (_) async => http.StreamedResponse(stream, 500));

      final tokens = await service.generateStream(messages).toList();

      expect(tokens.first, contains('Erro ao conectar'));
    });

    test('handles SocketException', () async {
      when(() => client.send(any()))
          .thenAnswer((_) => Future.error(const SocketException('refused')));

      final tokens = await service.generateStream(messages).toList();

      expect(tokens, ['Erro de conexão. Verifique sua internet.']);
    });

    test('handles generic exception', () async {
      when(() => client.send(any()))
          .thenAnswer((_) => Future.error(Exception('unknown error')));

      final tokens = await service.generateStream(messages).toList();

      expect(tokens.length, 1);
      expect(tokens.first, contains('Erro ao conectar'));
    });
  });

  group('generate', () {
    test('concatenates stream tokens', () async {
      final sse = [
        'data: {"id":"1","choices":[{"index":0,"delta":{"content":"Hello"}}]}\n',
        'data: {"id":"2","choices":[{"index":0,"delta":{"content":" world"}}]}\n',
        'data: [DONE]\n',
      ].join();
      when(() => client.send(any()))
          .thenAnswer((_) async => _okResponse(sse));

      final result = await service.generate(messages);

      expect(result, 'Hello world');
    });
  });

  group('unloadModel', () {
    test('closes the HTTP client', () async {
      await service.unloadModel();

      verify(() => client.close()).called(1);
    });
  });
}
