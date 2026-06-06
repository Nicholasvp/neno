import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moon_design/moon_design.dart';

import '../../../app/theme/app_theme.dart';
import '../bloc/ai_bloc.dart';
import '../bloc/ai_event.dart';
import '../bloc/ai_state.dart';
import '../widgets/chat_bubble.dart';

class AiAdvicePage extends StatefulWidget {
  const AiAdvicePage({super.key});

  @override
  State<AiAdvicePage> createState() => _AiAdvicePageState();
}

class _AiAdvicePageState extends State<AiAdvicePage> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    context.read<AiBloc>().add(AiAdviceRequested(userMessage: text));
    _ctrl.clear();
    _scrollToBottom();
  }

  void _quickAdvice() {
    context.read<AiBloc>().add(const AiAdviceRequested());
    _scrollToBottom();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conselhos'),
        actions: [
          if (keyboardOpen)
            IconButton(
              tooltip: 'Minimizar teclado',
              icon: const Icon(Icons.keyboard_hide),
              onPressed: _dismissKeyboard,
            ),
        ],
      ),
      body: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const _AdvisorBanner(),
            Expanded(
              child: BlocConsumer<AiBloc, AiState>(
                listenWhen: (a, b) => a.history.length != b.history.length || a.status != b.status,
                listener: (_, __) => _scrollToBottom(),
                builder: (context, state) {
                  if (state.history.isEmpty) {
                    return _EmptyChat(
                      isLoading: state.status == AiStatus.thinking || state.status == AiStatus.streaming,
                      onSuggest: _quickAdvice,
                    );
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.history.length,
                    itemBuilder: (context, i) {
                      final turn = state.history[i];
                      return ChatBubble(
                        role: turn.role,
                        content: turn.content,
                        isStreaming: state.status == AiStatus.streaming && i == state.history.length - 1,
                      );
                    },
                  );
                },
              ),
            ),
            if (context.watch<AiBloc>().state.status == AiStatus.error)
              Container(
                color: Colors.red.shade50,
                padding: const EdgeInsets.all(8),
                child: Text(
                  context.read<AiBloc>().state.error ?? '',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            _Composer(controller: _ctrl, onSend: _send, onSuggest: _quickAdvice),
          ],
        ),
      ),
    );
  }
}

class _AdvisorBanner extends StatelessWidget {
  const _AdvisorBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiBloc, AiState>(
      buildWhen: (a, b) => a.llmAvailable != b.llmAvailable,
      builder: (context, state) {
        if (state.llmAvailable) {
          return Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'IA local ativa',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          width: double.infinity,
          color: AppTheme.accent.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates, color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Conselhos personalizados baseados na sua semana e movimentos',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend, required this.onSuggest});
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onSuggest;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            MoonTextButton(
              onTap: onSuggest,
              leading: Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: MoonTextInput(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                hintText: 'Pergunte algo...',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 4),
            MoonTextButton(
              onTap: onSend,
              leading: Icon(Icons.send, color: AppTheme.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.isLoading, required this.onSuggest});
  final bool isLoading;
  final VoidCallback onSuggest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_alt, size: 64, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              'Olá! Sou sua assistente de gestação.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Posso te dar conselhos baseados na sua semana de gestação e nos movimentos registrados.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const MoonCircularLoader()
            else
              MoonFilledButton(
                onTap: onSuggest,
                leading: const Icon(Icons.auto_awesome),
                label: const Text('Dar um conselho agora'),
              ),
          ],
        ),
      ),
    );
  }
}
