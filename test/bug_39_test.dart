import 'dart:io';

import 'package:path/path.dart' show dirname, join, normalize;
import 'package:test/test.dart';
import 'package:json_to_dart/json_to_dart.dart' show ModelGenerator;

String _scriptPath() {
  var script = Platform.script.toString();
  if (script.startsWith("file://")) {
    script = script.substring(7);
  } else {
    final idx = script.indexOf("file:/");
    script = script.substring(idx + 5);
  }
  return script;
}

void main() {
  group("model-generator", () {
    final currentDirectory = dirname(_scriptPath());

    test("Should generate the classes to parse the JSON", () {
      final jsonPath = normalize(join(currentDirectory, 'bug_39.json'));
      final jsonRawData = new File(jsonPath).readAsStringSync();
      final generator = ModelGenerator('BugThirtyNine');
      // FIXME: Add matrix support
      // final dartCode = generator.generateDartClasses(jsonRawData);
      // expect(dartCode.warnings.length, equals(0));
      // expect(dartCode.code.contains('class BugForty'), equals(true));
    });
  });
}
