import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

class ProfileSaved extends ProfileEvent {
  const ProfileSaved({required this.dueDate, this.name});
  final DateTime dueDate;
  final String? name;
  @override
  List<Object?> get props => [dueDate, name];
}

class ProfileCleared extends ProfileEvent {
  const ProfileCleared();
}
