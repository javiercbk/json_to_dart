import 'dart:io';
import '../lib/json_to_dart.dart';

main() {
  final classGenerator = new ModelGenerator('SearchIssueResponse');
  final jsonRawData = new File('./sample.json').readAsStringSync();
  String dartClassesStr = classGenerator.generateDartClasses(jsonRawData);
  print(dartClassesStr);
}