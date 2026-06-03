import 'package:equatable/equatable.dart';

import '../../../data/models/pregnancy_profile.dart';

enum ProfileStatus { initial, loading, loaded, empty }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
  });

  final ProfileStatus status;
  final PregnancyProfile? profile;

  ProfileState copyWith({
    ProfileStatus? status,
    PregnancyProfile? profile,
    bool clearProfile = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }

  @override
  List<Object?> get props => [status, profile];
}
