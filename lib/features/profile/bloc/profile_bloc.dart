import 'package:bloc/bloc.dart';

import '../../../data/models/pregnancy_profile.dart';
import '../../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileSaved>(_onSaved);
    on<ProfileCleared>(_onCleared);
  }

  final ProfileRepository _repository;

  void _onLoaded(ProfileLoaded event, Emitter<ProfileState> emit) {
    emit(state.copyWith(status: ProfileStatus.loading));
    final profile = _repository.get();
    if (profile == null) {
      emit(state.copyWith(status: ProfileStatus.empty, clearProfile: true));
    } else {
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    }
  }

  Future<void> _onSaved(ProfileSaved event, Emitter<ProfileState> emit) async {
    final profile = PregnancyProfile(
      name: event.name?.trim().isEmpty ?? true ? null : event.name!.trim(),
      dueDate: event.dueDate,
    );
    await _repository.save(profile);
    emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
  }

  Future<void> _onCleared(ProfileCleared event, Emitter<ProfileState> emit) async {
    await _repository.clear();
    emit(state.copyWith(status: ProfileStatus.empty, clearProfile: true));
  }
}
