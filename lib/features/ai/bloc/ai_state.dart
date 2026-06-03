import 'package:equatable/equatable.dart';

enum AiStatus { idle, thinking, streaming, error }

class ChatTurn extends Equatable {
  const ChatTurn({required this.role, required this.content});
  final String role;
  final String content;
  @override
  List<Object?> get props => [role, content];
}

class AiState extends Equatable {
  const AiState({
    this.status = AiStatus.idle,
    this.history = const [],
    this.error,
    this.llmAvailable = false,
  });

  final AiStatus status;
  final List<ChatTurn> history;
  final String? error;
  final bool llmAvailable;

  AiState copyWith({
    AiStatus? status,
    List<ChatTurn>? history,
    String? error,
    bool? llmAvailable,
    bool clearError = false,
  }) {
    return AiState(
      status: status ?? this.status,
      history: history ?? this.history,
      error: clearError ? null : (error ?? this.error),
      llmAvailable: llmAvailable ?? this.llmAvailable,
    );
  }

  @override
  List<Object?> get props => [status, history, error, llmAvailable];
}
