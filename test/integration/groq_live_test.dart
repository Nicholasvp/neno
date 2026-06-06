// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neno/core/config/env_loader.dart';
import 'package:neno/data/datasources/ai_service.dart';
import 'package:neno/data/datasources/groq_ai_service.dart';
import 'package:neno/data/datasources/rule_based_advisor.dart';
import 'package:neno/data/models/movement.dart';
import 'package:neno/data/models/pregnancy_profile.dart';
import 'package:neno/data/repositories/ai_repository.dart';

void main() {
  test('Chat real: usa o MESMO caminho do app (AiRepository + EnvLoader)',
      () async {
    final raw = File('.env').readAsStringSync();
    final values = EnvLoader.parse(raw);
    final apiKey = values['GROQ_API_KEY'] ?? '';
    print('Chave carregada do .env: '
        '${apiKey.isEmpty ? "<<VAZIA>>" : "${apiKey.substring(0, 6)}..."}'
        ' (${apiKey.length} chars)');

    final service = GroqAiService(apiKey: apiKey);
    final repo = AiRepositoryImpl(service, advisor: const RuleBasedAdvisor());

    final profile = PregnancyProfile(
      name: 'Maria',
      dueDate: DateTime.now().add(const Duration(days: 90)),
    );
    final movements = [
      Movement(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Movement(
        id: '2',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    print('========== STREAM DO CHAT (caminho real do app) ==========');
    final buffer = StringBuffer();
    await for (final token in repo.askStream(
      profile: profile,
      recentMovements: movements,
      userMessage: 'Tô com azia forte, o que faço?',
    )) {
      buffer.write(token);
      stdout.write(token);
    }
    print('\n=========================================================');
    print('Total: ${buffer.length} caracteres');
    print('Resposta começa com: "${buffer.toString().substring(0, buffer.length.clamp(0, 80))}..."');

    expect(apiKey, isNotEmpty, reason: 'Chave não foi lida do .env');
    expect(buffer.toString().trim(), isNotEmpty,
        reason: 'Nenhuma resposta do Groq');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
