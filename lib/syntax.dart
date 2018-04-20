import './helpers.dart';

class TypeDefinition {
  String name;
  String subtype;
  bool _isPrimitive = false;

  factory TypeDefinition.fromDynamic(dynamic obj) {
    final type = getTypeName(obj);
    if (type == 'List') {
      List<dynamic> list = obj;
      final firstElementType = getTypeName(list[0]);
      return new TypeDefinition(type, subtype: firstElementType);
    }
    return new TypeDefinition(type);
  }

  TypeDefinition(this.name, { this.subtype }) {
    if (subtype == null) {
      _isPrimitive = isPrimitiveType(this.name);
    } else {
      _isPrimitive = isPrimitiveType('$name<$subtype>');
    }
  }

  bool get isPrimitive => _isPrimitive;

  bool get isPrimitiveList => _isPrimitive && name.contains('List');

  operator ==(TypeDefinition other) {
    return name == other.name && subtype == other.subtype;
  }

  String _buildParseInt(String expression) {
    return "int.parse($expression, radix: 10, onError: (source) => null)";
  }

  String _buildParseDouble(String expression) {
    return "double.parse($expression, (source) => null)";
  }

  String _buildParseBool(String expression) {
    return "$expression.toLowerCase() == 'true' : null";
  }

  String _buildParseClass(String expression) {
    final properType = subtype != null ? subtype : name;
    return 'new $properType.fromJson($expression)';
  }

  String _buildToJsonClass(String expression) {
    return '$expression.toJson()';
  }

  String jsonParseExpression(String key) {
    final jsonKey = "json['$key']";
    final fieldKey = fixFieldName(key, this);
    if (isPrimitive && !isPrimitiveList) {
        switch (name) {
          case 'String':
            return "$fieldKey = json['$key'];";
          case 'int':
            return "$fieldKey = ${_buildParseInt(jsonKey)};";
          case 'double':
            return "$fieldKey = ${_buildParseDouble(jsonKey)};";
          default:
            // bool
            return "$fieldKey = json['$key'] != null ? ${_buildParseBool(jsonKey)};";
        }
      } else if (isPrimitiveList) {
        switch (subtype) {
          case 'String':
            return "$fieldKey = json['$key'];";
          case 'int':
            return "$fieldKey = json['$key'] != null ? json['$key'].map((v) => ${_buildParseInt('v')}) : null;";
          case 'double':
            return "$fieldKey = json['$key'] != null ? json['$key'].map((v) => ${_buildParseDouble('v')}) : null;";
          default:
            // bool
            return "$fieldKey = json['$key'] != null ? json['$key'].map((v) => ${_buildParseBool('v')}) : null;";
        }
      } else if (name.contains('List')) {
        // list of class
        return "$fieldKey = json['$key'] != null ? json['$key'].map((v) => ${_buildParseClass('v')}) : null;";
      } else {
        // class
        return "$fieldKey = json['$key'] != null ? ${_buildParseClass(jsonKey)} : null;";
      }
  }

  String toJsonExpression(String key) {
    final fieldKey = fixFieldName(key, this);
    final thisKey = 'this.$fieldKey';
    if (isPrimitive) {
      switch (name) {
        case 'String':
          return "data['$key'] = $thisKey;";
        default:
          // int, double, bool, List<primitive>
          return """if ($thisKey != null) {
      data['$key'] = $thisKey.toString();
    }""";
      }
    } else if (name == 'List'){
      // class list
      return """if ($thisKey != null) {
      data['$key'] = $thisKey.map((v) => ${_buildToJsonClass('v')});
    }""";
    } else {
      // class
      return """if ($thisKey != null) {
      data['$key'] = ${_buildToJsonClass(thisKey)};
    }""";
    }
  }
}

class Dependency {
  String name;
  final TypeDefinition typeDef;

  Dependency(this.name, this.typeDef);

  String get className => camelCase(name);
}

class ClassDefinition {
  final String _name;
  final Map<String, TypeDefinition> fields = new Map<String, TypeDefinition>();

  String get name => _name;

  List<Dependency> get dependencies {
    final dependenciesList = new List<Dependency>();
    final keys = fields.keys;
    keys.forEach((k) {
      if (!fields[k].isPrimitive) {
        dependenciesList.add(new Dependency(k, fields[k]));
      }
    });
    return dependenciesList;
  }

  ClassDefinition(this._name);

  hasField(TypeDefinition otherField) {
    return fields.keys.firstWhere((k) => fields[k] == otherField, orElse: () => null) != null;
  }

  addField(String name, TypeDefinition typeDef) {
    fields[name] = typeDef;
  }

  operator ==(ClassDefinition other) {
    if (name != other.name) {
      return false;
    }
    return fields.keys.firstWhere(
      (k) => other.fields.keys.firstWhere(
        (ok) => fields[k] == other.fields[ok], orElse: () => null
      ) == null, orElse: () => null
    ) == null;
  }

  String get _fieldList {
    return fields.keys.map((key) {
      final f = fields[key];
      final fieldName = fixFieldName(key, f);
      final sb = new StringBuffer();
      sb.write('\t${f.name}');
      if (f.subtype != null) {
        sb.write('<${f.subtype}>');
      }
      sb.write(' $fieldName;');
      return sb.toString();
    }).join('\n');
  }

  String get _jsonParseFunc {
    var sb = new StringBuffer();
    sb.write('\t$name');
    sb.write('.fromJson(Map<String, dynamic> json) {\n');
    fields.keys.forEach((k) {
      sb.write('\t\t${fields[k].jsonParseExpression(k)}\n');
    });
    sb.write('\t}');
    return sb.toString();
  }

  String get _jsonGenFunc {
    var sb = new StringBuffer();
    sb.write('\tMap<String, dynamic> toJson() {\n\t\tfinal Map<String, dynamic> data = new Map<String, dynamic>();\n');
    fields.keys.forEach((k) {
      sb.write('\t\t${fields[k].toJsonExpression(k)}\n');
    });
    sb.write('\t\treturn data;\n');
    sb.write('\t}');
    return sb.toString();
  }

  String toString() {
    return 'class $name {\n$_fieldList\n\n$_jsonParseFunc\n\n$_jsonGenFunc\n}\n';
  }

}