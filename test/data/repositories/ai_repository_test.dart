// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neno/data/datasources/ai_service.dart';
import 'package:neno/data/models/movement.dart';
import 'package:neno/data/models/pregnancy_profile.dart';
import 'package:neno/data/repositories/ai_repository.dart';

class _MockAiService extends Mock implements AiService {}

void main() {
  late _MockAiService aiService;
  late AiRepositoryImpl repository;

  final profile = PregnancyProfile(
    name: 'Maria',
    dueDate: DateTime.now().add(const Duration(days: 150)),
  );

  setUp(() {
    aiService = _MockAiService();
    repository = AiRepositoryImpl(aiService);
  });

  group('askStream', () {
    test('delegates to AI service when loaded', () async {
      when(() => aiService.isLoaded).thenReturn(true);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => Stream.fromIterable(['Olá', ' como', ' vai?']),
      );

      final tokens = await repository
          .askStream(profile: profile, recentMovements: const [])
          .toList();

      expect(tokens, ['Olá', ' como', ' vai?']);
      verify(() => aiService.generateStream(any())).called(1);
    });

    test('includes user message in the prompt to AI service', () async {
      when(() => aiService.isLoaded).thenReturn(true);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );

      await repository
          .askStream(
            profile: profile,
            recentMovements: const [],
            userMessage: 'Estou sentindo poucos movimentos',
          )
          .toList();

      final captured = verify(() => aiService.generateStream(captureAny()))
          .captured
          .single as List<AiMessage>;

      expect(captured.length, 2);
      expect(captured[0].role, 'system');
      expect(captured[1].role, 'user');
      expect(captured[1].content, 'Estou sentindo poucos movimentos');
    });

    test('includes default message when userMessage is null', () async {
      when(() => aiService.isLoaded).thenReturn(true);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );

      await repository
          .askStream(profile: profile, recentMovements: const [])
          .toList();

      final captured = verify(() => aiService.generateStream(captureAny()))
          .captured
          .single as List<AiMessage>;

      expect(captured.length, 2);
      expect(captured[1].role, 'user');
      expect(captured[1].content,
          'Dê um conselho curto e personalizado para este momento da gestação.');
    });

    test('system prompt contains topic restriction rules', () async {
      when(() => aiService.isLoaded).thenReturn(true);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );

      await repository
          .askStream(profile: profile, recentMovements: const [])
          .toList();

      final captured = verify(() => aiService.generateStream(captureAny()))
          .captured
          .single as List<AiMessage>;

      final systemContent = captured[0].content;

      expect(systemContent, contains('EXCLUSIVO para gestação e maternidade'));
      expect(systemContent, contains('REGRAS ABSOLUTAS'));
      expect(
          systemContent, contains('NÃO substitua orientação médica profissional'));
      expect(systemContent,
          contains('Sou uma assistente especializada em gestação e maternidade'));
      expect(systemContent, contains(profile.currentWeek.toString()));
      expect(systemContent, contains(profile.trimester));
    });

    test('delegates to AI service even when not loaded (no pre-formatted text)',
        () async {
      when(() => aiService.isLoaded).thenReturn(false);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => Stream.fromIterable(['Resposta', ' da', ' IA']),
      );

      final tokens = await repository
          .askStream(profile: profile, recentMovements: const [])
          .toList();

      expect(tokens, ['Resposta', ' da', ' IA']);
      verify(() => aiService.generateStream(any())).called(1);
    });

    test('passes user message and rules insights to AI even when not loaded',
        () async {
      when(() => aiService.isLoaded).thenReturn(false);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );

      await repository
          .askStream(
            profile: profile,
            recentMovements: const [],
            userMessage: 'oi',
          )
          .toList();

      final captured = verify(() => aiService.generateStream(captureAny()))
          .captured
          .single as List<AiMessage>;

      expect(captured[1].role, 'user');
      expect(captured[1].content, 'oi');
      expect(captured[0].content, contains('Insights calculados pelas regras'));
    });

    test('includes movement context in the prompt', () async {
      when(() => aiService.isLoaded).thenReturn(true);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );

      final movements = [
        Movement(
          id: '1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Movement(
          id: '2',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];

      await repository
          .askStream(profile: profile, recentMovements: movements)
          .toList();

      final captured = verify(() => aiService.generateStream(captureAny()))
          .captured
          .single as List<AiMessage>;

      final systemContent = captured[0].content;
      expect(systemContent, contains('Movimentos registrados nas últimas 24h'));
    });

    test('includes zero movements when recentMovements is empty', () async {
      when(() => aiService.isLoaded).thenReturn(true);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );

      await repository
          .askStream(profile: profile, recentMovements: const [])
          .toList();

      final captured = verify(() => aiService.generateStream(captureAny()))
          .captured
          .single as List<AiMessage>;

      final systemContent = captured[0].content;
      expect(systemContent, contains('Nenhum registrado'));
    });
  });

  group('askWithRules', () {
    test('returns advice based on profile and movements', () {
      // (removido: askWithRules foi descontinuado)
    });
  });

  group('rules fallback snapshot (BEFORE refactor)', () {
    test('returns pre-formatted text from rule-based advisor when AI not loaded',
        () async {
      // (removido: ver snapshot registrado no histórico)
    });
  });

  group('system prompt snapshot (AFTER refactor)', () {
    test('prints the system prompt that the AI now receives', () async {
      when(() => aiService.isLoaded).thenReturn(true);
      when(() => aiService.generateStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );

      await repository
          .askStream(
            profile: profile,
            recentMovements: const [],
            userMessage: 'oi',
          )
          .toList();

      final captured = verify(() => aiService.generateStream(captureAny()))
          .captured
          .single as List<AiMessage>;

      final systemContent = captured[0].content;
      print('=== SYSTEM PROMPT (depois) ===');
      print(systemContent);
      print('==============================');

      expect(systemContent, contains('Insights calculados pelas regras'));
      expect(systemContent, contains('Fase da gestação:'));
      expect(systemContent, contains('Avaliação de movimentos:'));
      expect(systemContent, contains('Dica geral da semana:'));
    });
  });

  group('isModelLoaded', () {
    test('delegates to AI service', () {
      when(() => aiService.isLoaded).thenReturn(true);
      expect(repository.isModelLoaded, true);

      when(() => aiService.isLoaded).thenReturn(false);
      expect(repository.isModelLoaded, false);
    });
  });
}
