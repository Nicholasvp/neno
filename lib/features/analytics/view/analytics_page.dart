import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_theme.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_charts.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análises')),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.empty) {
            return const _EmptyAnalytics();
          }
          return _AnalyticsBody(state: state);
        },
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.state});
  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Média diária',
                value: state.averageDaily.toStringAsFixed(1),
                icon: Icons.show_chart,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Intervalo médio',
                value: _formatInterval(state.averageIntervalMinutes),
                icon: Icons.timer,
                color: AppTheme.borderColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Sequência',
                value: '${state.streakDays}d',
                icon: Icons.local_fire_department,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ChartCard(
          title: 'Últimos 7 dias',
          subtitle: 'Movimentos por dia',
          child: Last7DaysChart(buckets: state.last7Days),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Distribuição por horário',
          subtitle: 'Quando o bebê mais se mexe',
          child: HourDistributionChart(buckets: state.hourDistribution),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Horário de pico',
          subtitle: _peakSubtitle(state.hourDistribution),
          child: _PeakHours(buckets: state.hourDistribution),
        ),
      ],
    );
  }

  String _formatInterval(double minutes) {
    if (minutes <= 0) return '—';
    if (minutes < 60) return '${minutes.toStringAsFixed(0)}min';
    final h = minutes ~/ 60;
    final m = (minutes % 60).round();
    return '${h}h${m > 0 ? '${m}min' : ''}';
  }

  String _peakSubtitle(List<HourBucket> buckets) {
    if (buckets.isEmpty) return '';
    final sorted = [...buckets]..sort((a, b) => b.count.compareTo(a.count));
    if (sorted.first.count == 0) return 'Sem dados ainda';
    return 'Entre ${sorted.first.hour}h e ${(sorted.first.hour + 1) % 24}h';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _PeakHours extends StatelessWidget {
  const _PeakHours({required this.buckets});
  final List<HourBucket> buckets;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();
    final sorted = [...buckets]..sort((a, b) => b.count.compareTo(a.count));
    final top = sorted.take(3).toList();
    return Column(
      children: [
        for (int i = 0; i < top.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.accent,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${top[i].hour}h — ${top[i].hour + 1}h'),
                ),
                Text(
                  '${top[i].count} mov.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              'Sem dados ainda',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Comece a registrar movimentos para ver suas análises.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
