import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:neno/data/models/movement.dart';
import 'package:neno/data/models/pregnancy_profile.dart';
import 'package:neno/data/repositories/ai_repository.dart';
import 'package:neno/data/repositories/movement_repository.dart';
import 'package:neno/features/ai/bloc/ai_bloc.dart';
import 'package:neno/features/ai/bloc/ai_event.dart';
import 'package:neno/features/ai/bloc/ai_state.dart';

class _MockAiRepository extends Mock implements AiRepository {}

class _MockMovementRepository extends Mock implements MovementRepository {}

class _FakePregnancyProfile extends Fake implements PregnancyProfile {}

class _FakeMovement extends Fake implements Movement {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePregnancyProfile());
    registerFallbackValue(_FakeMovement());
  });

  late _MockAiRepository aiRepo;
  late _MockMovementRepository movRepo;
  late StreamController<List<Movement>> movementsController;

  final profile = PregnancyProfile(dueDate: DateTime.now().add(const Duration(days: 100)));

  setUp(() {
    aiRepo = _MockAiRepository();
    movRepo = _MockMovementRepository();
    movementsController = StreamController<List<Movement>>.broadcast();
    when(() => movRepo.watch()).thenAnswer((_) => movementsController.stream);
    when(() => aiRepo.isModelLoaded).thenReturn(false);
    when(() => aiRepo.loadedModelName).thenReturn(null);
    when(() => aiRepo.askWithRules(
          profile: any(named: 'profile'),
          recentMovements: any(named: 'recentMovements'),
        )).thenReturn('Conselho teste');
  });

  tearDown(() async {
    await movementsController.close();
  });

  blocTest<AiBloc, AiState>(
    'uses rule-based advice when model not loaded',
    build: () => AiBloc(aiRepository: aiRepo, movementRepository: movRepo),
    act: (bloc) async {
      bloc.add(AiContextUpdated(profile: profile, movements: const []));
      bloc.add(const AiAdviceRequested());
    },
    wait: const Duration(milliseconds: 100),
    verify: (bloc) {
      expect(bloc.state.status, AiStatus.idle);
      expect(bloc.state.history.length, 1);
      expect(bloc.state.history.first.content, 'Conselho teste');
    },
  );

  blocTest<AiBloc, AiState>(
    'emits error when profile is null',
    build: () => AiBloc(aiRepository: aiRepo, movementRepository: movRepo),
    act: (bloc) => bloc.add(const AiAdviceRequested()),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.status, AiStatus.error);
    },
  );

  blocTest<AiBloc, AiState>(
    'adds user message to history when provided',
    build: () => AiBloc(aiRepository: aiRepo, movementRepository: movRepo),
    act: (bloc) async {
      bloc.add(AiContextUpdated(profile: profile, movements: const []));
      bloc.add(const AiAdviceRequested(userMessage: 'oi'));
    },
    wait: const Duration(milliseconds: 100),
    verify: (bloc) {
      expect(bloc.state.history.length, 2);
      expect(bloc.state.history[0].role, 'user');
      expect(bloc.state.history[0].content, 'oi');
    },
  );
}
