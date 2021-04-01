import 'dart:io';

import 'package:json_to_dart/model_generator.dart';
import 'package:path/path.dart' show dirname, join, normalize;
import 'package:json_to_dart/json_to_dart.dart' show ModelGenerator;
import 'package:test/test.dart';

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
      String jsonPath = normalize(join(currentDirectory, 'array_root.json'));
      String jsonRawData = new File(jsonPath).readAsStringSync();
      ModelGenerator generator = ModelGenerator('ArrayRoot');
      DartCode dartCode = generator.generateDartClasses(jsonRawData);
      expect(dartCode.warnings.length, equals(0));
      expect(dartCode.code.contains('class GlossDiv'), equals(true));
    });
  });
}
