import 'package:get_it/get_it.dart';

import '../../data/datasources/ai_service.dart';
import '../../data/datasources/groq_ai_service.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/movement_repository.dart';
import '../../data/repositories/profile_repository.dart';

final GetIt sl = GetIt.instance;

const _groqApiKey = String.fromEnvironment('GROQ_API_KEY');

Future<void> setupDependencies() async {
  await LocalStorage.instance.init();

  sl.registerSingleton<LocalStorage>(LocalStorage.instance);

  final aiService = _groqApiKey.isNotEmpty
      ? GroqAiService(apiKey: _groqApiKey) as AiService
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
