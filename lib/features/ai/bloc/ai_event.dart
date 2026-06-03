import 'package:equatable/equatable.dart';

import '../../../data/models/movement.dart';
import '../../../data/models/pregnancy_profile.dart';

abstract class AiEvent extends Equatable {
  const AiEvent();
  @override
  List<Object?> get props => [];
}

class AiContextUpdated extends AiEvent {
  const AiContextUpdated({required this.profile, required this.movements});
  final PregnancyProfile? profile;
  final List<Movement> movements;
  @override
  List<Object?> get props => [profile, movements];
}

class AiAdviceRequested extends AiEvent {
  const AiAdviceRequested({this.userMessage});
  final String? userMessage;
  @override
  List<Object?> get props => [userMessage];
}

class AiStopped extends AiEvent {
  const AiStopped();
}
