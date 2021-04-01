import 'package:json_ast/json_ast.dart' show Node;
import 'package:json_to_dart/helpers.dart';

const String emptyListWarn = 'list is empty';
const String ambiguousListWarn = 'list is ambiguous';
const String ambiguousTypeWarn = 'type is ambiguous';

class Warning {
  Warning(this.warning, this.path);
  final String warning;
  final String path;
}

Warning newEmptyListWarn(String path) => new Warning(emptyListWarn, path);

Warning newAmbiguousListWarn(String path) =>
    new Warning(ambiguousListWarn, path);

Warning newAmbiguousType(String path) => new Warning(ambiguousTypeWarn, path);

class WithWarning<T> {
  WithWarning(this.result, this.warnings);
  final T result;
  final List<Warning> warnings;
}

class TypeDefinition {
  TypeDefinition(
    this.name, {
    this.subtype,
    this.isAmbiguous,
    Node astNode,
  }) {
    if (subtype == null) {
      _isPrimitive = isPrimitiveType(this.name);
      if (this.name == 'int' && isASTLiteralDouble(astNode)) {
        this.name = 'double';
      }
    } else {
      _isPrimitive = isPrimitiveType('$name<$subtype>');
    }
    isAmbiguous ??= false;
  }

  factory TypeDefinition.fromDynamic(dynamic obj, Node astNode) {
    bool isAmbiguous = false;
    String type = getTypeName(obj);
    if (type == 'List') {
      List<dynamic> list = obj;
      String elemType;
      if (list.length > 0) {
        elemType = getTypeName(list[0]);
        for (dynamic listVal in list) {
          if (elemType != getTypeName(listVal)) {
            isAmbiguous = true;
            break;
          }
        }
      } else {
        // when array is empty insert Null just to warn the user
        elemType = 'Null';
      }
      return new TypeDefinition(type,
          astNode: astNode, subtype: elemType, isAmbiguous: isAmbiguous);
    }
    return new TypeDefinition(type, astNode: astNode, isAmbiguous: isAmbiguous);
  }
  String name;
  String subtype;
  bool isAmbiguous = false;
  bool _isPrimitive = false;

  bool operator ==(dynamic other) {
    if (other is TypeDefinition) {
      TypeDefinition otherTypeDef = other;
      return this.name == otherTypeDef.name &&
          this.subtype == otherTypeDef.subtype &&
          this.isAmbiguous == otherTypeDef.isAmbiguous &&
          this._isPrimitive == otherTypeDef._isPrimitive;
    }
    return false;
  }

  bool get isPrimitive => _isPrimitive;

  bool get isPrimitiveList => _isPrimitive && name == 'List';

  String _buildParseClass(String expression) {
    String properType = subtype != null ? subtype : name;
    return 'new $properType.fromJson($expression)';
  }

  String _buildToJsonClass(String expression) => '$expression.toJson()';

  String jsonParseExpression(String key, bool privateField) {
    String jsonKey = "json['$key']";
    String fieldKey =
        fixFieldName(key, typeDef: this, privateField: privateField);
    if (isPrimitive) {
      if (name == 'List') {
        return "$fieldKey = json['$key'].cast<$subtype>();";
      }
      return "$fieldKey = json['$key'];";
    } else if (name == 'List' && subtype == 'DateTime') {
      return "$fieldKey = json['$key'].map((v) => DateTime.tryParse(v));";
    } else if (name == 'DateTime') {
      return "$fieldKey = DateTime.tryParse(json['$key']);";
    } else if (name == 'List') {
      // list of class
      return '''
if (json['$key'] != null) {\n\t\t\t$fieldKey = new List<$subtype>();\n\t\t\tjson['$key'].forEach((v) { $fieldKey.add(new $subtype.fromJson(v)); });\n\t\t}''';
    } else {
      // class
      return '''
$fieldKey = json['$key'] != null ? ${_buildParseClass(jsonKey)} : null;''';
    }
  }

  String toJsonExpression(String key, bool privateField) {
    String fieldKey =
        fixFieldName(key, typeDef: this, privateField: privateField);
    String thisKey = 'this.$fieldKey';
    if (isPrimitive) {
      return '''
data['$key'] = $thisKey;''';
    } else if (name == 'List') {
      // class list
      return '''if ($thisKey != null) {
      data['$key'] = $thisKey.map((v) => ${_buildToJsonClass('v')}).toList();
    }''';
    } else {
      // class
      return '''if ($thisKey != null) {
      data['$key'] = ${_buildToJsonClass(thisKey)};
    }''';
    }
  }
}

class Dependency {
  Dependency(this.name, this.typeDef);
  String name;
  final TypeDefinition typeDef;

  String get className => camelCase(name);
}

class ClassDefinition {
  ClassDefinition(this._name, [this._privateFields = false]);
  final String _name;
  final bool _privateFields;
  final Map<String, TypeDefinition> fields = new Map<String, TypeDefinition>();

  String get name => _name;
  bool get privateFields => _privateFields;

  List<Dependency> get dependencies {
    List<Dependency> dependenciesList = <Dependency>[];
    Iterable<String> keys = fields.keys;
    keys.forEach((String k) {
      TypeDefinition f = fields[k];
      if (!f.isPrimitive) {
        dependenciesList.add(new Dependency(k, f));
      }
    });
    return dependenciesList;
  }

  bool operator ==(dynamic other) {
    assert(other != null);
    if (other is ClassDefinition) {
      ClassDefinition otherClassDef = other;
      return this.isSubsetOf(otherClassDef) && otherClassDef.isSubsetOf(this);
    }
    return false;
  }

  bool isSubsetOf(ClassDefinition other) {
    List<String> keys = this.fields.keys.toList();
    int len = keys.length;
    for (int i = 0; i < len; i++) {
      TypeDefinition otherTypeDef = other.fields[keys[i]];
      if (otherTypeDef != null) {
        TypeDefinition typeDef = this.fields[keys[i]];
        if (typeDef != otherTypeDef) {
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  bool hasField(TypeDefinition otherField) =>
      fields.keys.firstWhere((String k) => fields[k] == otherField,
          orElse: () => null) !=
      null;

  TypeDefinition addField(String name, TypeDefinition typeDef) =>
      fields[name] = typeDef;

  void _addTypeDef(TypeDefinition typeDef, StringBuffer sb) {
    sb.write('${typeDef.name}');
    if (typeDef.subtype != null) {
      sb.write('<${typeDef.subtype}>');
    }
  }

  String get _fieldList => fields.keys.map((String key) {
        TypeDefinition f = fields[key];
        String fieldName =
            fixFieldName(key, typeDef: f, privateField: privateFields);
        StringBuffer sb = new StringBuffer();
        sb.write('\t');
        _addTypeDef(f, sb);
        sb.write(' $fieldName;');
        return sb.toString();
      }).join('\n');

  String get _gettersSetters => fields.keys.map((String key) {
        TypeDefinition f = fields[key];
        String publicFieldName =
            fixFieldName(key, typeDef: f, privateField: false);
        String privateFieldName =
            fixFieldName(key, typeDef: f, privateField: true);
        StringBuffer sb = new StringBuffer();
        sb.write('\t');
        _addTypeDef(f, sb);
        sb.write('''
 get $publicFieldName => $privateFieldName;\n\tset $publicFieldName(''');
        _addTypeDef(f, sb);
        sb.write(' $publicFieldName) => $privateFieldName = $publicFieldName;');
        return sb.toString();
      }).join('\n');

  String get _defaultPrivateConstructor {
    StringBuffer sb = new StringBuffer();
    sb.write('\t$name({');
    int i = 0;
    int len = fields.keys.length - 1;
    fields.keys.forEach((String key) {
      TypeDefinition f = fields[key];
      String publicFieldName =
          fixFieldName(key, typeDef: f, privateField: false);
      _addTypeDef(f, sb);
      sb.write(' $publicFieldName');
      if (i != len) {
        sb.write(', ');
      }
      i++;
    });
    sb.write('}) {\n');
    fields.keys.forEach((String key) {
      TypeDefinition f = fields[key];
      String publicFieldName =
          fixFieldName(key, typeDef: f, privateField: false);
      String privateFieldName =
          fixFieldName(key, typeDef: f, privateField: true);
      sb.write('this.$privateFieldName = $publicFieldName;\n');
    });
    sb.write('}');
    return sb.toString();
  }

  String get _defaultConstructor {
    StringBuffer sb = new StringBuffer();
    sb.write('\t$name({');
    int i = 0;
    int len = fields.keys.length - 1;
    fields.keys.forEach((String key) {
      TypeDefinition f = fields[key];
      String fieldName =
          fixFieldName(key, typeDef: f, privateField: privateFields);
      sb.write('this.$fieldName');
      if (i != len) {
        sb.write(', ');
      }
      i++;
    });
    sb.write('});');
    return sb.toString();
  }

  String get _jsonParseFunc {
    StringBuffer sb = new StringBuffer();
    sb.write('\t$name');
    sb.write('.fromJson(Map<String, dynamic> json) {\n');
    fields.keys.forEach((String k) {
      sb.write('\t\t${fields[k].jsonParseExpression(k, privateFields)}\n');
    });
    sb.write('\t}');
    return sb.toString();
  }

  String get _jsonGenFunc {
    StringBuffer sb = new StringBuffer();
    sb.write('''
\tMap<String, dynamic> toJson() {\n\t\tfinal Map<String, dynamic> data = new Map<String, dynamic>();\n''');
    fields.keys.forEach((String k) {
      sb.write('\t\t${fields[k].toJsonExpression(k, privateFields)}\n');
    });
    sb.write('\t\treturn data;\n');
    sb.write('\t}');
    return sb.toString();
  }

  String toString() {
    if (privateFields) {
      return '''
class $name {\n$_fieldList\n\n$_defaultPrivateConstructor\n\n$_gettersSetters\n\n$_jsonParseFunc\n\n$_jsonGenFunc\n}\n''';
    } else {
      return '''
class $name {\n$_fieldList\n\n$_defaultConstructor\n\n$_jsonParseFunc\n\n$_jsonGenFunc\n}\n''';
    }
  }
}
