import 'dart:io';
import 'package:path/path.dart' show dirname, join, normalize;
import '../lib/json_to_dart.dart';

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
  ModelGenerator classGenerator = new ModelGenerator('Sample', true);
  String currentDirectory = dirname(_scriptPath());
  String filePath = normalize(join(currentDirectory, 'sample.json'));
  String jsonRawData = new File(filePath).readAsStringSync();
  DartCode dartCode = classGenerator.generateDartClasses(jsonRawData);
  print(dartCode.code);
}
