import "package:test/test.dart";
import '../lib/helpers.dart';
import '../lib/syntax.dart';

void main() {
  group("helpers", () {
    test("camelCase should correctly transform Strings", () {
      const Map<String, String> mappings = const {
        'kebab-case': 'KebabCase',
        'snake_case': 'SnakeCase',
        'CamelCase': 'CamelCase',
        'camelCase': 'CamelCase',
      };
      mappings.keys.forEach((key) {
        expect(camelCase(key), equals(mappings[key]));  
      });
    });
    test("camelCaseFirstLower should correctly transform Strings", () {
      const Map<String, String> mappings = const {
        'kebab-case': 'kebabCase',
        'snake_case': 'snakeCase',
        'CamelCase': 'camelCase',
        'camelCase': 'camelCase',
      };
      mappings.keys.forEach((key) {
        expect(camelCaseFirstLower(key), equals(mappings[key]));  
      });
    });

    test("fixFieldName should avoid offending variable names", () {
      expect(fixFieldName('48x48', new TypeDefinition('String')), equals('s48x48'));
      expect(fixFieldName('_avoidPrivate', new TypeDefinition('String')), equals('sAvoidPrivate'));
    });
  });
}