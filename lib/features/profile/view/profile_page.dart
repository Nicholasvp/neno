import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/models/pregnancy_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.initial ||
              state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProfileStatus.empty || state.profile == null) {
            return const _EmptyProfile();
          }
          return _ProfileBody(profile: state.profile!);
        },
      ),
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  const _EmptyProfile();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pregnant_woman, size: 80, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              'Vamos configurar sua gestação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Informe a data prevista do parto (DPP) para acompanhar sua semana automaticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: const EditProfilePage(),
                  ),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar gestação'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});
  final PregnancyProfile profile;

  @override
  Widget build(BuildContext context) {
    final dppLabel = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(profile.dueDate);
    final dumLabel = DateFormat("dd/MM/yyyy").format(profile.lastMenstrualPeriod);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WeekCard(profile: profile),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.cake,
                  label: 'DPP (Data Provável do Parto)',
                  value: dppLabel,
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'DUM (Última menstruação)',
                  value: dumLabel,
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.timelapse,
                  label: 'Dias até o parto',
                  value: '${profile.daysUntilDue} dias',
                ),
                if (profile.name != null) ...[
                  const Divider(),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Mamãe',
                    value: profile.name!,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProfileBloc>(),
                child: EditProfilePage(initial: profile),
              ),
            ),
          ),
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _confirmClear(context),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text('Remover gestação', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover gestação?'),
        content: const Text('Isso apagará os dados da sua gestação atual. Os movimentos registrados não serão afetados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ProfileBloc>().add(const ProfileCleared());
              Navigator.pop(context);
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.profile});
  final PregnancyProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              profile.trimester,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${profile.currentWeek}',
                    style: const TextStyle(fontSize: 64, height: 1),
                  ),
                  const TextSpan(
                    text: '  semanas',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Text(
              '+ ${profile.currentWeekDays} dias',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: profile.progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
