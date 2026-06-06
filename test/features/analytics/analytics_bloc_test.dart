import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:neno/data/models/movement.dart';
import 'package:neno/data/repositories/movement_repository.dart';
import 'package:neno/features/analytics/bloc/analytics_bloc.dart';
import 'package:neno/features/analytics/bloc/analytics_event.dart';
import 'package:neno/features/analytics/bloc/analytics_state.dart';

class _MockMovementRepository extends Mock implements MovementRepository {}

void main() {
  late _MockMovementRepository repo;
  late StreamController<List<Movement>> controller;

  setUp(() {
    repo = _MockMovementRepository();
    controller = StreamController<List<Movement>>.broadcast();
    when(() => repo.watch()).thenAnswer((_) => controller.stream);
    when(() => repo.getAll()).thenReturn([]);
  });

  tearDown(() async {
    await controller.close();
  });

  blocTest<AnalyticsBloc, AnalyticsState>(
    'emits loaded state with 7 day buckets when movements exist',
    build: () => AnalyticsBloc(repository: repo),
    act: (bloc) async {
      bloc.add(const AnalyticsSubscribed());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final now = DateTime.now();
      controller.add([
        Movement(id: '1', timestamp: now),
        Movement(id: '2', timestamp: now.subtract(const Duration(days: 1))),
        Movement(id: '3', timestamp: now.subtract(const Duration(days: 2))),
      ]);
    },
    skip: 1,
    expect: () => [
      isA<AnalyticsState>()
          .having((s) => s.status, 'status', AnalyticsStatus.loaded)
          .having((s) => s.last7Days.length, 'buckets', 7)
          .having((s) => s.averageDaily, 'avg > 0', greaterThan(0)),
    ],
  );

  blocTest<AnalyticsBloc, AnalyticsState>(
    'emits empty state when no movements',
    build: () => AnalyticsBloc(repository: repo),
    act: (bloc) async {
      bloc.add(const AnalyticsSubscribed());
    },
    expect: () => [
      isA<AnalyticsState>().having((s) => s.status, 'status', AnalyticsStatus.empty),
    ],
  );
}
