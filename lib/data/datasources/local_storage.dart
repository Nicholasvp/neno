import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/movement.dart';
import '../models/pregnancy_profile.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  static const String _movementsBoxName = 'movements';
  static const String _profileBoxName = 'profile';
  static const String _profileKey = 'current';

  late final Box<Movement> _movementsBox;
  late final Box<PregnancyProfile> _profileBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    Hive.registerAdapter(MovementAdapter());
    Hive.registerAdapter(PregnancyProfileAdapter());
    _movementsBox = await Hive.openBox<Movement>(_movementsBoxName);
    _profileBox = await Hive.openBox<PregnancyProfile>(_profileBoxName);
    _initialized = true;
  }

  List<Movement> getAllMovements() {
    final list = _movementsBox.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> addMovement(Movement movement) async {
    await _movementsBox.put(movement.id, movement);
  }

  Future<void> deleteMovement(String id) async {
    await _movementsBox.delete(id);
  }

  PregnancyProfile? getProfile() => _profileBox.get(_profileKey);

  Future<void> saveProfile(PregnancyProfile profile) async {
    await _profileBox.put(_profileKey, profile);
  }

  Future<void> clearProfile() async {
    await _profileBox.delete(_profileKey);
  }
}
