import 'dart:io';

import 'package:test/test.dart';
import 'package:json_to_dart/json_to_dart.dart' show ModelGenerator;

void main() {
  group("model-generator", () {
    test("Should generate the classes to parse the JSON", () {
      final jsonRawData =
          new File("test_resources/bug_40.json").readAsStringSync();
      final generator = ModelGenerator('BugForty');
      final dartCode = generator.generateDartClasses(jsonRawData);
      expect(dartCode.warnings.length, equals(1));
      expect(dartCode.warnings[0].warning, equals("list is empty"));
      expect(dartCode.warnings[0].path, equals("/CustomButtons"));
      expect(dartCode.code.contains('class BugForty'), equals(true));
    });
  });
}
