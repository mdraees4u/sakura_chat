// Create test file: test/security_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  test('No hardcoded API keys in source', () {
    final directory = Directory('lib');
    final files = directory.listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final content = file.readAsStringSync();

      // Check for common API key patterns
      expect(content.contains('AIza'), false,
          reason: 'Potential API key found in ${file.path}');
      expect(content.contains('api_key ='), false,
          reason: 'API key assignment found in ${file.path}');
      expect(content.contains('apiKey:'), false,
          reason: 'API key found in ${file.path}');
    }
  });
}