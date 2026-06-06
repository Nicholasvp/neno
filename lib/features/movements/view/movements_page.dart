import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moon_design/moon_design.dart';

import '../../../app/theme/app_theme.dart';
import '../bloc/movements_bloc.dart';
import '../bloc/movements_event.dart';
import '../bloc/movements_state.dart';
import 'add_movement_sheet.dart';
import '../widgets/movement_card.dart';

class MovementsPage extends StatelessWidget {
  const MovementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimentos')),
      body: BlocBuilder<MovementsBloc, MovementsState>(
        builder: (context, state) => _Body(state: state),
      ),
      floatingActionButton: MoonFilledButton(
        onTap: () => _onAdd(context),
        leading: const Icon(Icons.add, size: 20),
        label: const Text('Registrar movimento'),
      ),
    );
  }

  void _onAdd(BuildContext context) {
    showMoonModalBottomSheet(
      context: context,
      isExpanded: false,
      builder: (_) => BlocProvider.value(
        value: context.read<MovementsBloc>(),
        child: const AddMovementSheet(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final MovementsState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _SummaryRow(state: state),
          ),
        ),
        if (state.movements.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            sliver: SliverList.separated(
              itemCount: state.movements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final m = state.movements[i];
                return MovementCard(
                  movement: m,
                  onDelete: () => context
                      .read<MovementsBloc>()
                      .add(MovementDeleted(m.id)),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});
  final MovementsState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Hoje',
            value: state.countToday.toString(),
            icon: Icons.today,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Últimas 24h',
            value: state.countLast24h.toString(),
            icon: Icons.access_time,
            color: AppTheme.borderColor,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(color: AppTheme.primary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 80, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              'Nenhum movimento ainda',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Toque em "Registrar movimento" para começar a acompanhar.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
