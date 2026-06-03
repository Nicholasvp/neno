import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:neno/data/models/movement.dart';
import 'package:neno/data/repositories/movement_repository.dart';
import 'package:neno/features/movements/bloc/movements_bloc.dart';
import 'package:neno/features/movements/bloc/movements_event.dart';
import 'package:neno/features/movements/bloc/movements_state.dart';

class _MockMovementRepository extends Mock implements MovementRepository {}

class _FakeMovement extends Fake implements Movement {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeMovement());
  });

  late _MockMovementRepository repo;
  late StreamController<List<Movement>> controller;

  setUp(() {
    repo = _MockMovementRepository();
    controller = StreamController<List<Movement>>.broadcast();
    when(() => repo.watch()).thenAnswer((_) => controller.stream);
    when(() => repo.add(any())).thenAnswer((_) async {});
    when(() => repo.delete(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await controller.close();
  });

  blocTest<MovementsBloc, MovementsState>(
    'emits [loading, loaded] when subscription pushes movements',
    build: () => MovementsBloc(repository: repo),
    act: (bloc) async {
      bloc.add(const MovementsSubscribed());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller.add([Movement(id: '1', timestamp: DateTime(2025, 1, 1))]);
    },
    skip: 1,
    expect: () => [
      isA<MovementsState>().having((s) => s.status, 'status', MovementsStatus.loaded),
    ],
  );

  blocTest<MovementsBloc, MovementsState>(
    'MovementAdded calls repository.add',
    build: () => MovementsBloc(repository: repo),
    act: (bloc) async {
      bloc.add(MovementAdded(timestamp: DateTime(2025, 1, 1, 10, 30), intensity: 2));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    verify: (_) {
      verify(() => repo.add(any())).called(1);
    },
  );

  blocTest<MovementsBloc, MovementsState>(
    'MovementDeleted calls repository.delete',
    build: () => MovementsBloc(repository: repo),
    act: (bloc) async {
      bloc.add(const MovementDeleted('abc'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    verify: (_) {
      verify(() => repo.delete('abc')).called(1);
    },
  );
}
