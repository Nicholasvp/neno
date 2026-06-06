import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:neno/data/models/pregnancy_profile.dart';
import 'package:neno/data/repositories/profile_repository.dart';
import 'package:neno/features/profile/bloc/profile_bloc.dart';
import 'package:neno/features/profile/bloc/profile_event.dart';
import 'package:neno/features/profile/bloc/profile_state.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _FakePregnancyProfile extends Fake implements PregnancyProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePregnancyProfile());
  });

  late _MockProfileRepository repo;

  setUp(() {
    repo = _MockProfileRepository();
  });

  blocTest<ProfileBloc, ProfileState>(
    'emits empty when repository returns null',
    build: () {
      when(() => repo.get()).thenReturn(null);
      return ProfileBloc(repository: repo);
    },
    act: (bloc) => bloc.add(const ProfileLoaded()),
    expect: () => [
      isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.empty),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits loaded when repository returns profile',
    build: () {
      when(() => repo.get()).thenReturn(
        PregnancyProfile(dueDate: DateTime(2025, 12, 1)),
      );
      return ProfileBloc(repository: repo);
    },
    act: (bloc) => bloc.add(const ProfileLoaded()),
    expect: () => [
      isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loaded),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'ProfileSaved calls repository.save and emits loaded',
    build: () {
      when(() => repo.save(any())).thenAnswer((_) async {});
      return ProfileBloc(repository: repo);
    },
    act: (bloc) => bloc.add(
      ProfileSaved(dueDate: DateTime(2025, 12, 1), name: 'Maria'),
    ),
    expect: () => [
      isA<ProfileState>()
          .having((s) => s.status, 'status', ProfileStatus.loaded)
          .having((s) => s.profile?.name, 'name', 'Maria'),
    ],
    verify: (_) {
      verify(() => repo.save(any())).called(1);
    },
  );

  blocTest<ProfileBloc, ProfileState>(
    'ProfileCleared calls repository.clear and emits empty',
    build: () {
      when(() => repo.clear()).thenAnswer((_) async {});
      return ProfileBloc(repository: repo);
    },
    act: (bloc) => bloc.add(const ProfileCleared()),
    expect: () => [
      isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.empty),
    ],
    verify: (_) {
      verify(() => repo.clear()).called(1);
    },
  );
}
