import 'package:dart_style/dart_style.dart';
import 'package:json_ast/json_ast.dart' show parse, Settings, Node;
import './helpers.dart';
import './syntax.dart';

class DartCode extends WithWarning<String> {
  DartCode(String result, List<Warning> warnings) : super(result, warnings);

  String get code => this.result;
}

/// A Hint is a user type correction.
class Hint {
  final String path;
  final String type;

  Hint(this.path, this.type);
}

class ModelGenerator {
  final String _rootClassName;
  final bool _privateFields;
  List<ClassDefinition> allClasses = new List<ClassDefinition>();
  List<Hint> hints;

  ModelGenerator(this._rootClassName, [this._privateFields = false, hints]) {
    if (hints != null) {
      this.hints = hints;
    } else {
      this.hints = new List<Hint>();
    }
  }

  Hint _hintForPath(String path) {
    return this.hints.firstWhere((h) => h.path == path, orElse: () => null);
  }

  List<Warning> _generateClassDefinition(String className,
      Map<dynamic, dynamic> jsonRawData, String path, Node astNode) {
    List<Warning> warnings = new List<Warning>();
    if (jsonRawData is List) {
      // if first element is an array, start in the first element.
      final node = navigateNode(astNode, '0');
      _generateClassDefinition(className, jsonRawData[0], path, node);
    } else {
      final keys = jsonRawData.keys;
      ClassDefinition classDefinition =
          new ClassDefinition(className, _privateFields);
      keys.forEach((key) {
        TypeDefinition typeDef;
        final hint = _hintForPath('$path/$key');
        final node = navigateNode(astNode, key);
        if (hint != null) {
          typeDef = new TypeDefinition(hint.type, astNode: node);
        } else {
          typeDef = new TypeDefinition.fromDynamic(jsonRawData[key], node);
        }
        if (typeDef.name == 'Class') {
          typeDef.name = camelCase(key);
        }
        if (typeDef.name == 'List' && typeDef.subtype == 'Null') {
          warnings.add(newEmptyListWarn('$path/$key'));
        }
        if (typeDef.subtype != null && typeDef.subtype == 'Class') {
          typeDef.subtype = camelCase(key);
        }
        if (typeDef.isAmbiguous) {
          warnings.add(newAmbiguousListWarn('$path/$key'));
        }
        classDefinition.addField(key, typeDef);
      });
      if (allClasses.firstWhere((cd) => cd == classDefinition,
              orElse: () => null) ==
          null) {
        allClasses.add(classDefinition);
      }
      final dependencies = classDefinition.dependencies;
      dependencies.forEach((dependency) {
        List<Warning> warns;
        if (dependency.typeDef.name == 'List') {
          // only generate dependency class if the array is not empty
          if (jsonRawData[dependency.name].length > 0) {
            // when list has ambiguous values, take the first one, otherwise merge all objects
            // into a single one
            dynamic toAnalyze;
            if (!dependency.typeDef.isAmbiguous) {
              WithWarning<Map> mergeWithWarning = mergeList(
                  jsonRawData[dependency.name], '$path/${dependency.name}');
              toAnalyze = mergeWithWarning.result;
              warnings.addAll(mergeWithWarning.warnings);
            } else {
              toAnalyze = jsonRawData[dependency.name][0];
            }
            final node = navigateNode(astNode, dependency.name);
            warns = _generateClassDefinition(dependency.className, toAnalyze,
                '$path/${dependency.name}', node);
          }
        } else {
          final node = navigateNode(astNode, dependency.name);
          warns = _generateClassDefinition(dependency.className,
              jsonRawData[dependency.name], '$path/${dependency.name}', node);
        }
        if (warns != null) {
          warnings.addAll(warns);
        }
      });
    }
    return warnings;
  }

  /// generateUnsafeDart will generate all classes and append one after another
  /// in a single string. The [rawJson] param is assumed to be a properly
  /// formatted JSON string. The dart code is not validated so invalid dart code
  /// might be returned
  DartCode generateUnsafeDart(String rawJson) {
    final Map<String, dynamic> jsonRawData = decodeJSON(rawJson);
    final astNode = parse(rawJson, Settings());
    List<Warning> warnings =
        _generateClassDefinition(_rootClassName, jsonRawData, "", astNode);
    return new DartCode(
        allClasses.map((c) => c.toString()).join('\n'), warnings);
  }

  /// generateDartClasses will generate all classes and append one after another
  /// in a single string. The [rawJson] param is assumed to be a properly
  /// formatted JSON string. If the generated dart is invalid it will throw an error.
  DartCode generateDartClasses(String rawJson) {
    final unsafeDartCode = generateUnsafeDart(rawJson);
    final formatter = new DartFormatter();
    return new DartCode(
        formatter.format(unsafeDartCode.code), unsafeDartCode.warnings);
  }
}
