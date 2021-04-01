import 'package:test/test.dart';
import 'package:json_to_dart/helpers.dart';
import 'package:json_to_dart/syntax.dart';

void main() {
  group('helpers', () {
    test('camelCase should correctly transform Strings', () {
      const Map<String, String> mappings = <String, String>{
        'kebab-case': 'KebabCase',
        'snake_case': 'SnakeCase',
        'CamelCase': 'CamelCase',
        'camelCase': 'CamelCase',
      };
      mappings.keys.forEach((String key) {
        expect(camelCase(key), equals(mappings[key]));
      });
    });
    test('camelCaseFirstLower should correctly transform Strings', () {
      const Map<String, String> mappings = <String, String>{
        'kebab-case': 'kebabCase',
        'snake_case': 'snakeCase',
        'CamelCase': 'camelCase',
        'camelCase': 'camelCase',
      };
      mappings.keys.forEach((String key) {
        expect(camelCaseFirstLower(key), equals(mappings[key]));
      });
    });

    test('fixFieldName should avoid offending variable names', () {
      expect(
          fixFieldName('48x48',
              typeDef: new TypeDefinition(
                'String',
              ),
              privateField: false),
          equals('s48x48'));
      expect(
          fixFieldName('_avoidPrivate',
              typeDef: new TypeDefinition('String'), privateField: false),
          equals('sAvoidPrivate'));
      expect(
          fixFieldName('48x48',
              typeDef: new TypeDefinition('String'), privateField: true),
          equals('_s48x48'));
      expect(
          fixFieldName('_avoidPrivate',
              typeDef: new TypeDefinition('String'), privateField: true),
          equals('_sAvoidPrivate'));
    });
  });
}
