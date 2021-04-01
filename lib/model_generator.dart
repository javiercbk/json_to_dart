import 'dart:collection';

import 'package:dart_style/dart_style.dart';
import 'package:json_ast/json_ast.dart' show parse, Settings, Node;
import 'package:json_to_dart/helpers.dart';
import 'package:json_to_dart/syntax.dart';

class DartCode extends WithWarning<String> {
  DartCode(String result, List<Warning> warnings) : super(result, warnings);

  String get code => this.result;
}

/// A Hint is a user type correction.
class Hint {
  Hint(this.path, this.type);
  final String path;
  final String type;
}

class ModelGenerator {
  ModelGenerator(this._rootClassName,
      [this._privateFields = false, this.hints]) {
    if (hints != null) {
      this.hints = hints;
    } else {
      this.hints = <Hint>[];
    }
  }
  final String _rootClassName;
  final bool _privateFields;
  List<ClassDefinition> allClasses = <ClassDefinition>[];
  final Map<String, String> sameClassMapping = new HashMap<String, String>();
  List<Hint> hints;

  Hint _hintForPath(String path) =>
      this.hints.firstWhere((Hint h) => h.path == path, orElse: () => null);

  List<Warning> _generateClassDefinition(
      String className, dynamic jsonRawDynamicData, String path, Node astNode) {
    List<Warning> warnings = <Warning>[];
    if (jsonRawDynamicData is List) {
      // if first element is an array, start in the first element.
      Node node = navigateNode(astNode, '0');
      _generateClassDefinition(className, jsonRawDynamicData[0], path, node);
    } else {
      Map<dynamic, dynamic> jsonRawData = jsonRawDynamicData;
      Iterable<dynamic> keys = jsonRawData.keys;
      ClassDefinition classDefinition =
          new ClassDefinition(className, _privateFields);
      keys.forEach((dynamic key) {
        TypeDefinition typeDef;
        Hint hint = _hintForPath('$path/$key');
        Node node = navigateNode(astNode, key);
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
      ClassDefinition similarClass = allClasses.firstWhere(
          (ClassDefinition cd) => cd == classDefinition,
          orElse: () => null);
      if (similarClass != null) {
        String similarClassName = similarClass.name;
        String currentClassName = classDefinition.name;
        sameClassMapping[currentClassName] = similarClassName;
      } else {
        allClasses.add(classDefinition);
      }
      List<Dependency> dependencies = classDefinition.dependencies;
      dependencies.forEach((Dependency dependency) {
        List<Warning> warns;
        if (dependency.typeDef.name == 'List') {
          // only generate dependency class if the array is not empty
          if (jsonRawData[dependency.name].length > 0) {
            // when list has ambiguous values,
            // take the first one, otherwise merge all objects
            // into a single one
            dynamic toAnalyze;
            if (!dependency.typeDef.isAmbiguous) {
              WithWarning<Map<dynamic, dynamic>> mergeWithWarning =
                  mergeObjectList(
                      jsonRawData[dependency.name], '$path/${dependency.name}');
              toAnalyze = mergeWithWarning.result;
              warnings.addAll(mergeWithWarning.warnings);
            } else {
              toAnalyze = jsonRawData[dependency.name][0];
            }
            Node node = navigateNode(astNode, dependency.name);
            warns = _generateClassDefinition(dependency.className, toAnalyze,
                '$path/${dependency.name}', node);
          }
        } else {
          Node node = navigateNode(astNode, dependency.name);
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
    dynamic jsonRawData = decodeJSON(rawJson);
    Node astNode = parse(rawJson, Settings());
    List<Warning> warnings =
        _generateClassDefinition(_rootClassName, jsonRawData, '', astNode);
    // after generating all classes, replace the omited similar classes.
    allClasses.forEach((ClassDefinition c) {
      Iterable<String> fieldsKeys = c.fields.keys;
      fieldsKeys.forEach((String f) {
        TypeDefinition typeForField = c.fields[f];
        if (sameClassMapping.containsKey(typeForField.name)) {
          c.fields[f].name = sameClassMapping[typeForField.name];
        }
      });
    });
    return new DartCode(
        allClasses.map((ClassDefinition c) => c.toString()).join('\n'),
        warnings);
  }

  /// generateDartClasses will generate all classes and append one after another
  /// in a single string. The [rawJson] param is assumed to be a properly
  /// formatted JSON string. 
  /// If the generated dart is invalid it will throw an error.
  DartCode generateDartClasses(String rawJson) {
    DartCode unsafeDartCode = generateUnsafeDart(rawJson);
    DartFormatter formatter = new DartFormatter();
    return new DartCode(
        formatter.format(unsafeDartCode.code), unsafeDartCode.warnings);
  }
}
