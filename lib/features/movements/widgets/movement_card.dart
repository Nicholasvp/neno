import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/models/movement.dart';

class MovementCard extends StatelessWidget {
  const MovementCard({super.key, required this.movement, this.onDelete});

  final Movement movement;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat("HH:mm").format(movement.timestamp);
    final dateLabel = DateFormat("dd 'de' MMM", 'pt_BR').format(movement.timestamp);
    final intensityLabel = movement.intensity == null
        ? null
        : ['', 'Leve', 'Médio', 'Forte'][movement.intensity!];

    return Dismissible(
      key: ValueKey(movement.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (movement.notes != null && movement.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        movement.notes!,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (intensityLabel != null)
                MoonTag(
                  label: Text(
                    intensityLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppTheme.accent.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
