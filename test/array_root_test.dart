import 'dart:io';

import 'package:json_to_dart/json_to_dart.dart' show ModelGenerator;
import 'package:test/test.dart';

void main() {
  group("model-generator", () {
    test("Should generate the classes to parse the JSON", () {
      final jsonRawData =
          new File("test_resources/array_root.json").readAsStringSync();
      final generator = ModelGenerator('ArrayRoot');
      final dartCode = generator.generateDartClasses(jsonRawData);
      expect(dartCode.warnings.length, equals(0));
      expect(dartCode.code.contains('class GlossDiv'), equals(true));
    });
  });
}
