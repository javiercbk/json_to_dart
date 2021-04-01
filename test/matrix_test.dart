import 'dart:io';

import 'package:path/path.dart' show dirname, join, normalize;
import 'package:test/test.dart';
import 'package:json_to_dart/json_to_dart.dart' show ModelGenerator;

String _scriptPath() {
  String script = Platform.script.toString();
  if (script.startsWith('file://')) {
    script = script.substring(7);
  } else {
    int idx = script.indexOf('file:/');
    script = script.substring(idx + 5);
  }
  return script;
}

void main() {
  group('model-generator', () {
    String currentDirectory = dirname(_scriptPath());

    test('Should generate the classes to parse the JSON', () {
      String jsonPath = normalize(join(currentDirectory, 'matrix.json'));
      String jsonRawData = new File(jsonPath).readAsStringSync();
      ModelGenerator generator = ModelGenerator('Matrix');
      // FIXME: Add matrix support
      // final dartCode = generator.generateDartClasses(jsonRawData);
      // expect(dartCode.warnings.length, equals(1));
      // expect(dartCode.code.contains('class Matrix'), equals(true));
    });
  });
}
