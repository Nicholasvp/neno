import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

import '../../../app/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.role,
    required this.content,
    this.isStreaming = false,
  });

  final String role;
  final String content;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                content.isEmpty && isStreaming ? '...' : content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.primaryDark,
                  height: 1.35,
                ),
              ),
            ),
            if (isStreaming) ...[
              const SizedBox(width: 6),
              const SizedBox(
                width: 8,
                height: 8,
                child: MoonCircularLoader(strokeWidth: 1.5, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
