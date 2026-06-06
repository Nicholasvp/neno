import 'dart:async';
import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';

import '../../../data/datasources/ai_service.dart';
import '../../../data/models/movement.dart';
import '../../../data/models/pregnancy_profile.dart';
import '../../../data/repositories/ai_repository.dart';
import '../../../data/repositories/movement_repository.dart';
import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  AiBloc({
    required AiRepository aiRepository,
    required MovementRepository movementRepository,
  })  : _aiRepository = aiRepository,
        _movementRepository = movementRepository,
        super(AiState(llmAvailable: aiRepository.isModelLoaded)) {
    on<AiContextUpdated>(_onContextUpdated);
    on<AiAdviceRequested>(_onAdviceRequested);
    on<AiStopped>(_onStopped);

    _movementsSub = _movementRepository.watch().listen((list) {
      add(AiContextUpdated(profile: _profile, movements: list));
    });
  }

  final AiRepository _aiRepository;
  final MovementRepository _movementRepository;
  StreamSubscription<List<Movement>>? _movementsSub;
  PregnancyProfile? _profile;
  List<Movement> _movements = const [];

  void _onContextUpdated(AiContextUpdated event, Emitter<AiState> emit) {
    _profile = event.profile;
    _movements = event.movements;
  }

  Future<void> _onAdviceRequested(
    AiAdviceRequested event,
    Emitter<AiState> emit,
  ) async {
    if (_profile == null) {
      emit(state.copyWith(
        status: AiStatus.error,
        error: 'Cadastre sua gestação na aba Perfil para receber conselhos.',
      ));
      return;
    }

    final userMessage = event.userMessage?.trim();
    final newHistory = [
      ...state.history,
      if (userMessage != null && userMessage.isNotEmpty)
        ChatTurn(role: 'user', content: userMessage),
    ];
    emit(state.copyWith(
      status: AiStatus.thinking,
      history: newHistory,
      clearError: true,
    ));

    try {
      dev.log('AiBloc: iniciando stream do assistente');
      emit(state.copyWith(status: AiStatus.streaming));
      final updatedHistory = [...newHistory, ChatTurn(role: 'assistant', content: '')];
      var accumulated = '';
      final historyForAi = newHistory
          .map((t) => AiMessage(role: t.role, content: t.content))
          .toList();
      await for (final partial in _aiRepository.askStream(
        profile: _profile!,
        recentMovements: _movements,
        userMessage: userMessage,
        history: historyForAi,
      )) {
        accumulated += partial;
        updatedHistory[updatedHistory.length - 1] =
            ChatTurn(role: 'assistant', content: accumulated);
        emit(state.copyWith(
          status: AiStatus.streaming,
          history: List.of(updatedHistory),
        ));
      }
      dev.log('AiBloc: stream concluído | tamanho: ${accumulated.length}');
      emit(state.copyWith(status: AiStatus.idle));
    } catch (e) {
      dev.log('AiBloc: erro - $e');
      emit(state.copyWith(status: AiStatus.error, error: e.toString()));
    }
  }

  void _onStopped(AiStopped event, Emitter<AiState> emit) {
    emit(state.copyWith(status: AiStatus.idle));
  }

  @override
  Future<void> close() {
    _movementsSub?.cancel();
    return super.close();
  }
}
