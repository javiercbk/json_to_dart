import 'package:dart_style/dart_style.dart';
import './helpers.dart';
import './syntax.dart';

class ModelGenerator {
  final String _rootClassName;
  final bool _privateFields;
  List<ClassDefinition> allClasses = new List<ClassDefinition>();
  
  ModelGenerator(this._rootClassName, [this._privateFields = false]);
  
  _generateClassDefinition(String className, Map<String, dynamic> jsonRawData) {
    if (jsonRawData is List) {
      // if first element is an array, start in the first element.
      _generateClassDefinition(className, jsonRawData[0]);
    } else {
      final keys = jsonRawData.keys;
      ClassDefinition classDefinition = new ClassDefinition(className, _privateFields);
      keys.forEach((key) {
        final typeDef = new TypeDefinition.fromDynamic(jsonRawData[key]);
        if (typeDef.name == 'Class') {
          typeDef.name = camelCase(key);
        }
        if (typeDef.subtype != null && typeDef.subtype == 'Class') {
          typeDef.subtype = camelCase(key);
        }
        classDefinition.addField(key, typeDef);
      });
      if (allClasses.firstWhere((cd) => cd == classDefinition, orElse: () => null) == null) {
        allClasses.add(classDefinition);
      }
      final dependencies = classDefinition.dependencies;
      dependencies.forEach((dependency) {
        if (dependency.typeDef.name == 'List') {
          if (jsonRawData[dependency.name].length > 0) {
            // only generate dependency class if the array is not empty
            _generateClassDefinition(dependency.className, jsonRawData[dependency.name][0]);
          }
        } else {
          _generateClassDefinition(dependency.className, jsonRawData[dependency.name]);
        }
      });
    }
  }

  /// generateUnsafeDart will generate all classes and append one after another
  /// in a single string. The [rawJson] param is assumed to be a properly
  /// formatted JSON string. The dart code is not validated so invalid dart code
  /// might be returned
  String generateUnsafeDart(String rawJson) {
    final Map<String, dynamic> jsonRawData = decodeJSON(rawJson);
    _generateClassDefinition(_rootClassName, jsonRawData);
    return allClasses.map((c) => c.toString()).join('\n');
  }

  /// generateDartClasses will generate all classes and append one after another
  /// in a single string. The [rawJson] param is assumed to be a properly
  /// formatted JSON string. If the generated dart is invalid it will throw an error.
  String generateDartClasses(String rawJson) {
    final unsafeDart = generateUnsafeDart(rawJson);
    final formatter = new DartFormatter();
    return formatter.format(unsafeDart);
  }
}