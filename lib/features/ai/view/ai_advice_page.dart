import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conselhos')),
      body: Column(
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
          child: const Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppTheme.primaryDark, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conselhos personalizados baseados na sua semana e movimentos',
                  style: TextStyle(color: AppTheme.primaryDark, fontSize: 12),
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
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: AppTheme.primary),
              tooltip: 'Conselho automático',
              onPressed: onSuggest,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Pergunte algo...',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: false,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppTheme.primary),
              onPressed: onSend,
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
            const Icon(Icons.psychology_alt, size: 64, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              'Olá! Sou sua assistente de gestação.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Posso te dar conselhos baseados na sua semana de gestação e nos movimentos registrados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                onPressed: onSuggest,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Dar um conselho agora'),
              ),
          ],
        ),
      ),
    );
  }
}
