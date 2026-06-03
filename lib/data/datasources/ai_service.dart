class AiMessage {
  const AiMessage({required this.role, required this.content});

  final String role;
  final String content;
}

abstract class AiService {
  bool get isLoaded;
  String? get loadedModelName;
  Future<bool> loadModel({String? modelPath, String? modelId});
  Future<void> unloadModel();
  Stream<String> generateStream(String prompt);
  Future<String> generate(String prompt);
}

class StubAiService implements AiService {
  @override
  bool get isLoaded => false;

  @override
  String? get loadedModelName => null;

  @override
  Future<bool> loadModel({String? modelPath, String? modelId}) async => false;

  @override
  Future<void> unloadModel() async {}

  @override
  Stream<String> generateStream(String prompt) async* {
    yield 'IA local indisponível.';
  }

  @override
  Future<String> generate(String prompt) async => 'IA local indisponível.';
}
