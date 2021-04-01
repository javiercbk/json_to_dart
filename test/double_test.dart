import 'dart:io';
import 'package:path/path.dart' show dirname, join, normalize;
import 'package:json_ast/json_ast.dart' show LiteralNode;
import 'package:test/test.dart';

import 'package:json_to_dart/model_generator.dart';
import 'package:json_to_dart/helpers.dart' show isASTLiteralDouble;

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
  group('Should identify doubles and ints', () {
    String currentDirectory = dirname(_scriptPath());

    test('should parse literals correctly', () {
      expect(isASTLiteralDouble(LiteralNode(1, '1')), isFalse);
      expect(isASTLiteralDouble(LiteralNode(1e0, '1e0')), isFalse);
      expect(isASTLiteralDouble(LiteralNode(1e1, '1e1')), isFalse);
      expect(isASTLiteralDouble(LiteralNode(1.1e1, '1.1e1')), isFalse);
      expect(isASTLiteralDouble(LiteralNode(10e-1, '10e-1')), isFalse);
      expect(
          isASTLiteralDouble(LiteralNode(1000.000e-1, '1000.000e-1')), isFalse);
      expect(isASTLiteralDouble(LiteralNode(1000.0e-1, '1000.0e-1')), isFalse);
      expect(isASTLiteralDouble(LiteralNode(1000.0e-0, '1000.0e-0')), isFalse);
      expect(
          isASTLiteralDouble(LiteralNode(10.0000e-1, '10.0000e-1')), isFalse);
      expect(
          isASTLiteralDouble(LiteralNode(10.000000000000000000000000001,
              '10.000000000000000000000000001')),
          isTrue);
      expect(isASTLiteralDouble(LiteralNode(10.0, '10.0')), isTrue);
      expect(isASTLiteralDouble(LiteralNode(10.1e0, '10.1e0')), isTrue);
      expect(isASTLiteralDouble(LiteralNode(10.01e1, '10.01e1')), isTrue);
      expect(isASTLiteralDouble(LiteralNode(11e-1, '11e-1')), isTrue);
      expect(isASTLiteralDouble(LiteralNode(11.0000e-1, '11.0000e-1')), isTrue);
      expect(isASTLiteralDouble(LiteralNode(0.1, '0.1')), isTrue);
    });

    test('Should identify a double number and generate the proper type', () {
      String jsonPath = normalize(join(currentDirectory, 'double.json'));
      String jsonRawData = new File(jsonPath).readAsStringSync();
      ModelGenerator modelGenerator = ModelGenerator('DoubleTest');
      DartCode dartSourceCode =
          modelGenerator.generateDartClasses(jsonRawData);
      RegExp wrongDoubleRegExp = RegExp(r'^.*double int[0-9]+;$');
      RegExp wrongIntRegExp = RegExp(r'^.*int double[0-9]+;$');
      RegExpMatch wrongDoubleMatch =
          wrongDoubleRegExp.firstMatch(dartSourceCode.code);
      RegExpMatch wrongIntMatch =
          wrongIntRegExp.firstMatch(dartSourceCode.code);
      expect(wrongDoubleMatch, isNull, reason: 'Wrong double found');
      expect(wrongIntMatch, isNull, reason: 'Wrong int found');
    });
  });
}
