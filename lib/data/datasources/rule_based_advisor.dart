import '../../data/models/movement.dart';
import '../../data/models/pregnancy_profile.dart';

class AdvisorContext {
  const AdvisorContext({
    required this.profile,
    required this.recentMovements,
    required this.movementsLast24h,
    required this.averageDailyMovements,
  });

  final PregnancyProfile profile;
  final List<Movement> recentMovements;
  final int movementsLast24h;
  final double averageDailyMovements;
}

class AdvisorInsights {
  const AdvisorInsights({
    required this.trimesterPhase,
    required this.movementAssessment,
    required this.generalTip,
    this.lastMovementSummary,
  });

  final String trimesterPhase;
  final String movementAssessment;
  final String generalTip;
  final String? lastMovementSummary;
}

class RuleBasedAdvisor {
  const RuleBasedAdvisor();

  AdvisorInsights extractInsights(AdvisorContext context) {
    final week = context.profile.currentWeek;
    return AdvisorInsights(
      trimesterPhase: _trimesterPhase(week),
      movementAssessment: _movementAssessment(
        week: week,
        last24h: context.movementsLast24h,
        avg: context.averageDailyMovements,
      ),
      generalTip: _generalTip(week),
      lastMovementSummary: _lastMovementSummary(context),
    );
  }

  String _trimesterPhase(int week) {
    if (week < 13) {
      return '1º trimestre — movimentos fetais ainda sutis e irregulares; não é esperado padrão definido.';
    }
    if (week < 20) {
      return 'Início da percepção de movimentos (geralmente entre 18ª e 20ª semana).';
    }
    if (week < 28) {
      return '2º trimestre — movimentos se intensificam gradualmente; sem necessidade de contagem rígida.';
    }
    if (week < 37) {
      return '3º trimestre — contagem de movimentos recomendada (meta: 10 movimentos em 2h após refeição).';
    }
    return 'Final da gestação — padrão de movimentos pode mudar pelo menor espaço uterino.';
  }

  String _movementAssessment({
    required int week,
    required int last24h,
    required double avg,
  }) {
    if (week < 28) {
      return 'Antes da 28ª semana a regularidade não é o foco (last24h=$last24h).';
    }
    if (last24h == 0) {
      return '⚠️ Nenhum movimento nas últimas 24h na $weekª semana — avaliar com obstetra.';
    }
    if (last24h >= 10) {
      return 'Movimentos adequados (last24h=$last24h).';
    }
    if (last24h >= 6) {
      return 'Movimentos dentro do esperado, mas atenção (last24h=$last24h).';
    }
    final belowAvg = avg > 0 && last24h < avg * 0.5;
    if (belowAvg) {
      return 'Movimentos abaixo da média recente (last24h=$last24h, média=${avg.toStringAsFixed(1)}).';
    }
    return 'Movimentos reduzidos (last24h=$last24h).';
  }

  String? _lastMovementSummary(AdvisorContext context) {
    if (context.recentMovements.isEmpty) return null;
    final last = context.recentMovements.first;
    final hours = DateTime.now().difference(last.timestamp).inHours;
    if (hours < 1) return 'há menos de 1 hora';
    if (hours < 24) return 'há ${hours}h';
    return 'há mais de 24h';
  }

  String _generalTip(int week) {
    const tips = <int, String>{
      1: 'Mantenha hidratação e ácido fólico em dia.',
      2: 'Comece a pesquisar sobre pré-natal e exames.',
      3: 'Faça as consultas de pré-natal mensalmente.',
      4: 'Comece a planejar o quarto e os itens do bebê.',
      5: 'Faça as ultrassons morfológicas do 2º trimestre.',
      6: 'Inscreva-se em curso de gestantes com seu parceiro.',
      7: 'Atenção à contagem de movimentos a partir de agora.',
      8: 'Converse com seu médico sobre o plano de parto.',
      9: 'Tenha a mala da maternidade pronta a partir da 36ª semana.',
      10: 'Descanse bastante — seu corpo está se preparando para o parto.',
    };

    final trimester = ((week - 1) ~/ 4).clamp(0, 9);
    return tips[trimester] ?? 'Confie no seu instinto e converse sempre com seu obstetra.';
  }
}
