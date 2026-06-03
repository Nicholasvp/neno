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

class RuleBasedAdvisor {
  const RuleBasedAdvisor();

  String getAdvice(AdvisorContext context) {
    final week = context.profile.currentWeek;
    final trimester = context.profile.trimester;
    final last24h = context.movementsLast24h;
    final avg = context.averageDailyMovements;

    final parts = <String>[];

    parts.add(
      'Você está na semana $week de gestação (${context.profile.currentWeekDays} dias) — $trimester. ',
    );

    if (week < 13) {
      parts.add(
        'No 1º trimestre, os movimentos do bebê ainda são sutis e podem não ser percebidos com regularidade. ',
      );
    } else if (week < 20) {
      parts.add(
        'Entre a 18ª e 20ª semana geralmente é quando os primeiros movimentos são sentidos. ',
      );
    } else if (week < 28) {
      parts.add(
        'No 2º trimestre, é normal sentir os movimentos se intensificarem gradualmente. ',
      );
    } else if (week < 37) {
      parts.add(
        'No 3º trimestre, é recomendado contar os movimentos: o ideal é sentir pelo menos 10 movimentos em 2 horas após uma refeição. ',
      );
    } else {
      parts.add(
        'Próximo ao nascimento, os movimentos podem mudar de padrão — o espaço está menor, então chutes e solavancos podem parecer diferentes. ',
      );
    }

    if (week >= 28) {
      if (last24h >= 10) {
        parts.add(
          'Nas últimas 24h você registrou $last24h movimentos — um ótimo sinal de vitalidade. Continue monitorando. ',
        );
      } else if (last24h >= 6) {
        parts.add(
          'Nas últimas 24h você registrou $last24h movimentos. Está dentro do esperado, mas fique atenta. ',
        );
      } else if (last24h > 0) {
        parts.add(
          'Apenas $last24h movimentos nas últimas 24h. Tente deitar-se do lado esquerdo após uma refeição e contar por 2 horas. ',
        );
      } else {
        parts.add(
          '⚠️ Nenhum movimento registrado nas últimas 24h. Se você está na $weekª semana, procure atendimento médico para avaliação. ',
        );
      }

      if (avg > 0 && last24h < avg * 0.5) {
        parts.add(
          'Sua média diária é ${avg.toStringAsFixed(1)} movimentos e hoje está bem abaixo — vale repetir a contagem em ambiente calmo. ',
        );
      }
    } else {
      parts.add(
        'Nas últimas 24h: $last24h registros. A regularidade ainda não é prioridade antes da 28ª semana. ',
      );
    }

    if (context.recentMovements.isNotEmpty) {
      final last = context.recentMovements.first;
      final timeSince = DateTime.now().difference(last.timestamp);
      if (timeSince.inHours < 1) {
        parts.add('Seu último movimento foi há menos de 1 hora. ');
      } else if (timeSince.inHours < 24) {
        parts.add('Seu último movimento foi há ${timeSince.inHours}h. ');
      } else {
        parts.add('Seu último movimento foi há mais de 24h. ');
      }
    }

    parts.add(_generalTip(week));

    return parts.join();
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
