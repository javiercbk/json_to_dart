import 'dart:io';
import 'package:json_ast/json_ast.dart' show LiteralNode;
import 'package:test/test.dart';

import 'package:json_to_dart/model_generator.dart';
import 'package:json_to_dart/helpers.dart' show isASTLiteralDouble;

void main() {
  group("Should identify doubles and ints", () {
    test("should parse literals correctly", () {
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

    test("Should identify a double number and generate the proper type", () {
      final jsonRawData =
          new File("test_resources/double.json").readAsStringSync();
      final modelGenerator = ModelGenerator('DoubleTest');
      final dartSourceCode = modelGenerator.generateDartClasses(jsonRawData);
      final wrongDoubleRegExp = RegExp(r"^.*double int[0-9]+;$");
      final wrongIntRegExp = RegExp(r"^.*int double[0-9]+;$");
      final wrongDoubleMatch =
          wrongDoubleRegExp.firstMatch(dartSourceCode.code);
      final wrongIntMatch = wrongIntRegExp.firstMatch(dartSourceCode.code);
      expect(wrongDoubleMatch, isNull, reason: 'Wrong double found');
      expect(wrongIntMatch, isNull, reason: 'Wrong int found');
    });
  });
}
