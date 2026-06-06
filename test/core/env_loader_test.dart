import 'package:flutter_test/flutter_test.dart';
import 'package:neno/core/config/env_loader.dart';

void main() {
  group('EnvLoader.parse', () {
    test('parses simple KEY=VALUE pairs', () {
      final result = EnvLoader.parse('''
GROQ_API_KEY=abc123
OTHER=hello
''');
      expect(result['GROQ_API_KEY'], 'abc123');
      expect(result['OTHER'], 'hello');
    });

    test('ignores comments and blank lines', () {
      final result = EnvLoader.parse('''
# this is a comment

GROQ_API_KEY=secret

# another comment
''');
      expect(result.length, 1);
      expect(result['GROQ_API_KEY'], 'secret');
    });

    test('strips surrounding quotes', () {
      final result = EnvLoader.parse('''
A="double"
B='single'
C=no-quotes
''');
      expect(result['A'], 'double');
      expect(result['B'], 'single');
      expect(result['C'], 'no-quotes');
    });
  });
}
