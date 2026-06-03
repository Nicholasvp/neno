import 'package:equatable/equatable.dart';

import '../../../data/models/movement.dart';

abstract class MovementsEvent extends Equatable {
  const MovementsEvent();
  @override
  List<Object?> get props => [];
}

class MovementsSubscribed extends MovementsEvent {
  const MovementsSubscribed();
}

class MovementsReceived extends MovementsEvent {
  const MovementsReceived(this.movements);
  final List<Movement> movements;
  @override
  List<Object?> get props => [movements];
}

class MovementAdded extends MovementsEvent {
  const MovementAdded({required this.timestamp, this.notes, this.intensity});

  final DateTime timestamp;
  final String? notes;
  final int? intensity;

  @override
  List<Object?> get props => [timestamp, notes, intensity];
}

class MovementDeleted extends MovementsEvent {
  const MovementDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
