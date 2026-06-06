import 'dart:developer' as dev;

import 'package:get_it/get_it.dart';

import '../../data/datasources/ai_service.dart';
import '../../data/datasources/groq_ai_service.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/movement_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../config/env_loader.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  await EnvLoader.load();
  await LocalStorage.instance.init();

  sl.registerSingleton<LocalStorage>(LocalStorage.instance);

  final apiKey = EnvLoader.get('GROQ_API_KEY');
  dev.log(
    'setupDependencies: GROQ_API_KEY length=${apiKey.length} '
    '| prefix=${apiKey.length >= 6 ? apiKey.substring(0, 6) : "<empty>"}',
  );
  final aiService = apiKey.isNotEmpty
      ? GroqAiService(apiKey: apiKey) as AiService
      : StubAiService();
  sl.registerSingleton<AiService>(aiService);

  sl.registerSingleton<MovementRepository>(
    MovementRepositoryImpl(sl<LocalStorage>()),
  );
  sl.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(sl<LocalStorage>()),
  );
  sl.registerSingleton<AiRepository>(
    AiRepositoryImpl(sl<AiService>()),
  );
}
