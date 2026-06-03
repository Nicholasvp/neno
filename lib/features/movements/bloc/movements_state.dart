import 'package:equatable/equatable.dart';

import '../../../data/models/movement.dart';

enum MovementsStatus { initial, loading, loaded, error }

class MovementsState extends Equatable {
  const MovementsState({
    this.status = MovementsStatus.initial,
    this.movements = const [],
    this.error,
  });

  final MovementsStatus status;
  final List<Movement> movements;
  final String? error;

  MovementsState copyWith({
    MovementsStatus? status,
    List<Movement>? movements,
    String? error,
  }) {
    return MovementsState(
      status: status ?? this.status,
      movements: movements ?? this.movements,
      error: error,
    );
  }

  int get countLast24h {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return movements.where((m) => m.timestamp.isAfter(cutoff)).length;
  }

  int get countToday {
    final now = DateTime.now();
    return movements.where((m) {
      return m.timestamp.year == now.year &&
          m.timestamp.month == now.month &&
          m.timestamp.day == now.day;
    }).length;
  }

  @override
  List<Object?> get props => [status, movements, error];
}
