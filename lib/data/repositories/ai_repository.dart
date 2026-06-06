import 'dart:async';
import 'dart:developer' as dev;

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
    List<AiMessage> history = const [],
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
    List<AiMessage> history = const [],
  }) async* {
    dev.log(
      'AiRepo: gerando resposta | isLoaded=${_aiService.isLoaded} '
      '| userMessage=${userMessage != null && userMessage.trim().isNotEmpty}',
    );
    final messages = _buildMessages(
      profile: profile,
      recentMovements: recentMovements,
      userMessage: userMessage,
      history: history,
    );
    await for (final token in _aiService.generateStream(messages)) {
      yield token;
    }
  }

  List<AiMessage> _buildMessages({
    required PregnancyProfile profile,
    required List<Movement> recentMovements,
    String? userMessage,
    List<AiMessage> history = const [],
  }) {
    final last24h = _countLast24h(recentMovements);
    final avg = _averageDaily(recentMovements);
    final movementsText = recentMovements.take(5).map((m) {
      return '- ${m.timestamp.toIso8601String()}';
    }).join('\n');

    final insights = _advisor.extractInsights(
      AdvisorContext(
        profile: profile,
        recentMovements: recentMovements,
        movementsLast24h: last24h,
        averageDailyMovements: avg,
      ),
    );

    final contextInfo = StringBuffer()
      ..writeln('Contexto da gestante:')
      ..writeln('- Semana de gestação: ${profile.currentWeek} + ${profile.currentWeekDays} dias')
      ..writeln('- Trimestre: ${profile.trimester}')
      ..writeln('- DPP: ${profile.dueDate.toIso8601String().split("T").first}')
      ..writeln('- Movimentos registrados nas últimas 24h: $last24h')
      ..writeln('- Média diária recente: ${avg.toStringAsFixed(1)}')
      ..writeln('- Últimos movimentos:')
      ..writeln(movementsText.isEmpty ? '- Nenhum registrado' : movementsText)
      ..writeln('')
      ..writeln('Insights calculados pelas regras (use como referência para personalizar):')
      ..writeln('- Fase da gestação: ${insights.trimesterPhase}')
      ..writeln('- Avaliação de movimentos: ${insights.movementAssessment}')
      ..writeln('- Dica geral da semana: ${insights.generalTip}');
    if (insights.lastMovementSummary != null) {
      contextInfo.writeln('- Último movimento registrado: ${insights.lastMovementSummary}');
    }

    final systemMessage = StringBuffer()
      ..writeln('Você é um assistente virtual EXCLUSIVO para gestação e maternidade.')
      ..writeln('')
      ..writeln('REGRAS ABSOLUTAS:')
      ..writeln('1. Responda SOMENTE sobre gestação, parto, amamentação, cuidados com o bebê, saúde da gestante,')
      ..writeln('   desenvolvimento fetal, alimentação na gestação, exames pré-natal e puerpério.')
      ..writeln('2. Se o usuário perguntar sobre QUALQUER OUTRO assunto (política, tecnologia, esportes,')
      ..writeln('   matemática, entretenimento, finanças, notícias, etc.), responda APENAS:')
      ..writeln('   "Sou uma assistente especializada em gestação e maternidade. Posso ajudar apenas com')
      ..writeln('   temas relacionados à gravidez, cuidados com o bebê e saúde da gestante."')
      ..writeln('   NÃO responda à pergunta off-topic de nenhuma forma.')
      ..writeln('3. NÃO substitua orientação médica profissional. Recomende consultar um obstetra quando necessário.')
      ..writeln('4. Responda em português do Brasil, de forma acolhedora, empática e breve (até 4 frases).')
      ..writeln('')
      ..write(contextInfo.toString().trim());

    final messages = <AiMessage>[
      AiMessage(role: 'system', content: systemMessage.toString()),
    ];

    for (final turn in history) {
      if (turn.content.trim().isEmpty) continue;
      messages.add(AiMessage(role: turn.role, content: turn.content.trim()));
    }

    if (userMessage != null && userMessage.trim().isNotEmpty) {
      messages.add(AiMessage(role: 'user', content: userMessage.trim()));
    } else {
      messages.add(const AiMessage(
        role: 'user',
        content: 'Dê um conselho curto e personalizado para este momento da gestação.',
      ));
    }

    return messages;
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
