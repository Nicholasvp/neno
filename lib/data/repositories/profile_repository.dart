import '../datasources/local_storage.dart';
import '../models/pregnancy_profile.dart';

abstract class ProfileRepository {
  PregnancyProfile? get();
  Future<void> save(PregnancyProfile profile);
  Future<void> clear();
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._storage);

  final LocalStorage _storage;

  @override
  PregnancyProfile? get() => _storage.getProfile();

  @override
  Future<void> save(PregnancyProfile profile) => _storage.saveProfile(profile);

  @override
  Future<void> clear() => _storage.clearProfile();
}
