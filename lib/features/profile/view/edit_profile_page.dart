import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/models/pregnancy_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, this.initial});
  final PregnancyProfile? initial;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late DateTime _dueDate;
  late TextEditingController _nameCtrl;
  int _selectedMode = 0;
  late DateTime _dum;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _dueDate = widget.initial?.dueDate ??
        DateTime.now().add(const Duration(days: 280));
    _dum = widget.initial?.lastMenstrualPeriod ??
        DateTime.now().subtract(const Duration(days: 280));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now().add(const Duration(days: 300)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dum = picked.subtract(const Duration(days: 280));
      });
    }
  }

  Future<void> _pickDum() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dum,
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dum = picked;
        _dueDate = picked.add(const Duration(days: 280));
      });
    }
  }

  void _save() {
    context.read<ProfileBloc>().add(
          ProfileSaved(
            dueDate: _dueDate,
            name: _nameCtrl.text,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dueLabel = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(_dueDate);
    final dumLabel = DateFormat("dd/MM/yyyy").format(_dum);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar gestação')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MoonTextInput(
            controller: _nameCtrl,
            hintText: 'Nome (opcional)',
            leading: const Icon(Icons.person),
          ),
          const SizedBox(height: 24),
          const Text(
            'Como você quer informar a data?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          MoonSegmentedControl(
            initialIndex: _selectedMode,
            onSegmentChanged: (i) => setState(() => _selectedMode = i),
            segments: [
              Segment(
                label: const Text('DPP'),
                leading: const Icon(Icons.cake),
              ),
              Segment(
                label: const Text('DUM'),
                leading: const Icon(Icons.calendar_today),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedMode == 0)
            _DatePicker(
              icon: Icons.cake,
              label: 'Data Provável do Parto (DPP)',
              value: dueLabel,
              onTap: _pickDueDate,
            )
          else
            _DatePicker(
              icon: Icons.calendar_today,
              label: 'Última menstruação (DUM)',
              value: dumLabel,
              onTap: _pickDum,
            ),
          const SizedBox(height: 16),
          Card(
            color: AppTheme.accent.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedMode == 0
                          ? 'Calculamos sua DUM subtraindo 280 dias da DPP.'
                          : 'Calculamos sua DPP adicionando 280 dias à DUM.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          MoonFilledButton(
            onTap: _save,
            isFullWidth: true,
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
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
                    Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
              const Icon(Icons.edit, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
