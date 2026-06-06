import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../data/models/movement.dart';
import '../../../data/repositories/movement_repository.dart';
import 'movements_event.dart';
import 'movements_state.dart';

class MovementsBloc extends Bloc<MovementsEvent, MovementsState> {
  MovementsBloc({required MovementRepository repository})
      : _repository = repository,
        super(const MovementsState()) {
    on<MovementsSubscribed>(_onSubscribed);
    on<MovementsReceived>(_onReceived);
    on<MovementAdded>(_onAdded);
    on<MovementDeleted>(_onDeleted);
  }

  final MovementRepository _repository;
  StreamSubscription? _subscription;

  Future<void> _onSubscribed(
    MovementsSubscribed event,
    Emitter<MovementsState> emit,
  ) async {
    await _subscription?.cancel();
    final current = _repository.getAll();
    emit(state.copyWith(
      status: MovementsStatus.loaded,
      movements: current,
    ));
    _subscription = _repository.watch().listen(
          (list) => add(MovementsReceived(list)),
        );
  }

  void _onReceived(MovementsReceived event, Emitter<MovementsState> emit) {
    emit(state.copyWith(
      status: MovementsStatus.loaded,
      movements: event.movements,
    ));
  }

  Future<void> _onAdded(
    MovementAdded event,
    Emitter<MovementsState> emit,
  ) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _repository.add(
      Movement(
        id: id,
        timestamp: event.timestamp,
        notes: event.notes,
        intensity: event.intensity,
      ),
    );
  }

  Future<void> _onDeleted(
    MovementDeleted event,
    Emitter<MovementsState> emit,
  ) async {
    await _repository.delete(event.id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
