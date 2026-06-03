import 'dart:async';

import '../datasources/ai_service.dart';
import '../datasources/rule_based_advisor.dart';
import '../models/movement.dart';
import '../models/pregnancy_profile.dart';

abstract class AiRepository {
  bool get isModelLoaded;
  String? get loadedModelName;
  Future<bool> loadModel({String? modelPath, String? modelId});
  Future<void> unloadModel();
  Stream<String> askStream({
    required PregnancyProfile profile,
    required List<Movement> recentMovements,
    String? userMessage,
  });
  String askWithRules({
    required PregnancyProfile profile,
    required List<Movement> recentMovements,
  });
  String buildContextPrompt({
    required PregnancyProfile profile,
    required List<Movement> recentMovements,
    String? userMessage,
  });
}

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._aiService, {RuleBasedAdvisor? advisor})
      : _advisor = advisor ?? const RuleBasedAdvisor();

  final AiService _aiService;
  final RuleBasedAdvisor _advisor;

  @override
  bool get isModelLoaded => _aiService.isLoaded;

  @override
  String? get loadedModelName => _aiService.loadedModelName;

  @override
  Future<bool> loadModel({String? modelPath, String? modelId}) =>
      _aiService.loadModel(modelPath: modelPath, modelId: modelId);

  @override
  Future<void> unloadModel() => _aiService.unloadModel();

  @override
  Stream<String> askStream({
    required PregnancyProfile profile,
    required List<Movement> recentMovements,
    String? userMessage,
  }) async* {
    final prompt = buildContextPrompt(
      profile: profile,
      recentMovements: recentMovements,
      userMessage: userMessage,
    );
    if (!_aiService.isLoaded) {
      yield _advisor.getAdvice(
        AdvisorContext(
          profile: profile,
          recentMovements: recentMovements,
          movementsLast24h: _countLast24h(recentMovements),
          averageDailyMovements: _averageDaily(recentMovements),
        ),
      );
      return;
    }
    final buffer = StringBuffer();
    await for (final token in _aiService.generateStream(prompt)) {
      buffer
        ..clear()
        ..write(token);
      yield token;
    }
  }

  @override
  String askWithRules({
    required PregnancyProfile profile,
    required List<Movement> recentMovements,
  }) {
    return _advisor.getAdvice(
      AdvisorContext(
        profile: profile,
        recentMovements: recentMovements,
        movementsLast24h: _countLast24h(recentMovements),
        averageDailyMovements: _averageDaily(recentMovements),
      ),
    );
  }

  @override
  String buildContextPrompt({
    required PregnancyProfile profile,
    required List<Movement> recentMovements,
    String? userMessage,
  }) {
    final last24h = _countLast24h(recentMovements);
    final avg = _averageDaily(recentMovements);
    final movementsText = recentMovements.take(20).map((m) {
      return '- ${m.timestamp.toIso8601String()}';
    }).join('\n');

    final sb = StringBuffer()
      ..writeln('Você é um assistente gentil e informativo para gestantes.')
      ..writeln('Responda em português do Brasil, de forma acolhedora e breve (até 4 frases).')
      ..writeln('NÃO substitua orientação médica profissional.')
      ..writeln('')
      ..writeln('Contexto:')
      ..writeln('- Semana de gestação: ${profile.currentWeek} + ${profile.currentWeekDays} dias')
      ..writeln('- Trimestre: ${profile.trimester}')
      ..writeln('- DPP: ${profile.dueDate.toIso8601String().split("T").first}')
      ..writeln('- Movimentos registrados nas últimas 24h: $last24h')
      ..writeln('- Média diária recente: ${avg.toStringAsFixed(1)}')
      ..writeln('- Últimos movimentos:')
      ..writeln(movementsText.isEmpty ? '- Nenhum registrado' : movementsText)
      ..writeln('');

    if (userMessage != null && userMessage.trim().isNotEmpty) {
      sb
        ..writeln('Pergunta da gestante:')
        ..writeln(userMessage)
        ..writeln('')
        ..writeln('Responda de forma acolhedora e informativa.');
    } else {
      sb.writeln('Dê um conselho curto e personalizado para este momento da gestação.');
    }

    return sb.toString();
  }

  int _countLast24h(List<Movement> movements) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return movements.where((m) => m.timestamp.isAfter(cutoff)).length;
  }

  double _averageDaily(List<Movement> movements) {
    if (movements.isEmpty) return 0;
    final byDay = <String, int>{};
    for (final m in movements) {
      final key = '${m.timestamp.year}-${m.timestamp.month}-${m.timestamp.day}';
      byDay[key] = (byDay[key] ?? 0) + 1;
    }
    final total = byDay.values.fold<int>(0, (a, b) => a + b);
    return total / byDay.length;
  }
}
