import 'dart:async';

import '../datasources/local_storage.dart';
import '../models/movement.dart';

abstract class MovementRepository {
  List<Movement> getAll();
  Future<void> add(Movement movement);
  Future<void> delete(String id);
  Stream<List<Movement>> watch();
}

class MovementRepositoryImpl implements MovementRepository {
  MovementRepositoryImpl(this._storage) {
    _controller = StreamController<List<Movement>>.broadcast(
      onListen: () => _controller.add(getAll()),
    );
  }

  final LocalStorage _storage;
  late final StreamController<List<Movement>> _controller;

  @override
  List<Movement> getAll() => _storage.getAllMovements();

  @override
  Future<void> add(Movement movement) async {
    await _storage.addMovement(movement);
    _controller.add(getAll());
  }

  @override
  Future<void> delete(String id) async {
    await _storage.deleteMovement(id);
    _controller.add(getAll());
  }

  @override
  Stream<List<Movement>> watch() => _controller.stream;
}
