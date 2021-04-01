import 'dart:convert' as Convert;
import 'dart:math';
import 'package:json_ast/json_ast.dart'
    show Node, ObjectNode, ArrayNode, LiteralNode;
import 'package:json_ast/tokenize.dart';
import 'package:json_to_dart/syntax.dart';

const Map<String, bool> PRIMITIVE_TYPES = const <String, bool>{
  'int': true,
  'double': true,
  'String': true,
  'bool': true,
  'DateTime': false,
  'List<DateTime>': false,
  'List<int>': true,
  'List<double>': true,
  'List<String>': true,
  'List<bool>': true,
  'Null': true,
};

enum ListType { Object, String, Double, Int, Null }

class MergeableListType {
  MergeableListType(this.listType, this.isAmbigous);
  final ListType listType;
  final bool isAmbigous;
}

MergeableListType mergeableListType(List<dynamic> list) {
  ListType t = ListType.Null;
  bool isAmbigous = false;
  list.forEach((dynamic e) {
    ListType inferredType;
    if (e.runtimeType == 'int') {
      inferredType = ListType.Int;
    } else if (e.runtimeType == 'double') {
      inferredType = ListType.Double;
    } else if (e.runtimeType == 'string') {
      inferredType = ListType.String;
    } else if (e is Map) {
      inferredType = ListType.Object;
    }
    if (t != ListType.Null && t != inferredType) {
      isAmbigous = true;
    }
    t = inferredType;
  });
  return MergeableListType(t, isAmbigous);
}

String camelCase(String text) {
  String capitalize(Match m) =>
      m[0].substring(0, 1).toUpperCase() + m[0].substring(1);
  String skip(String s) => '';
  return text.splitMapJoin(new RegExp(r'[a-zA-Z0-9]+'),
      onMatch: capitalize, onNonMatch: skip);
}

String camelCaseFirstLower(String text) {
  String camelCaseText = camelCase(text);
  String firstChar = camelCaseText.substring(0, 1).toLowerCase();
  String rest = camelCaseText.substring(1);
  return '$firstChar$rest';
}

dynamic decodeJSON(String rawJson) => Convert.json.decode(rawJson);

WithWarning<Map<dynamic, dynamic>> mergeObj(
    Map<dynamic, dynamic> obj, Map<dynamic, dynamic> other, String path) {
  List<Warning> warnings = <Warning>[];
  Map<dynamic, dynamic> clone = Map<dynamic, dynamic>.from(obj);
  other.forEach((dynamic k, dynamic v) {
    if (clone[k] == null) {
      clone[k] = v;
    } else {
      String otherType = getTypeName(v);
      String t = getTypeName(clone[k]);
      if (t != otherType) {
        if (t == 'int' && otherType == 'double') {
          // if double was found instead of int, assign the double
          clone[k] = v;
        } else if (clone[k].runtimeType != 'double' && v.runtimeType != 'int') {
          // if types are not equal, then
          warnings.add(newAmbiguousType('$path/$k'));
        }
      } else if (t == 'List') {
        List<dynamic> l = List<dynamic>.from(clone[k]);
        l.addAll(other[k]);
        MergeableListType mergeableType = mergeableListType(l);
        if (ListType.Object == mergeableType.listType) {
          WithWarning<Map<dynamic, dynamic>> mergedList =
              mergeObjectList(l, '$path');
          warnings.addAll(mergedList.warnings);
          clone[k] = List<Map<dynamic, dynamic>>.filled(1, mergedList.result);
        } else {
          if (l.length > 0) {
            clone[k] = List<Map<dynamic, dynamic>>.filled(1, l[0]);
          }
          if (mergeableType.isAmbigous) {
            warnings.add(newAmbiguousType('$path/$k'));
          }
        }
      } else if (t == 'Class') {
        WithWarning<Map<dynamic, dynamic>> mergedObj =
            mergeObj(clone[k], other[k], '$path/$k');
        warnings.addAll(mergedObj.warnings);
        clone[k] = mergedObj.result;
      }
    }
  });
  return new WithWarning<Map<dynamic, dynamic>>(clone, warnings);
}

WithWarning<Map<dynamic, dynamic>> mergeObjectList(
    List<dynamic> list, String path,
    [int idx = -1]) {
  List<Warning> warnings = <Warning>[];
  Map<dynamic, dynamic> obj = new Map<dynamic, dynamic>();
  for (int i = 0; i < list.length; i++) {
    dynamic toMerge = list[i];
    if (toMerge is Map) {
      toMerge.forEach((dynamic k, dynamic v) {
        assert(v != null);
        assert(k != null);
        String t = getTypeName(obj[k]);
        if (obj[k] == null) {
          obj[k] = v;
        } else {
          String otherType = getTypeName(v);
          if (t != otherType) {
            if (t == 'int' && otherType == 'double') {
              // if double was found instead of int, assign the double
              obj[k] = v;
            } else if (t != 'double' && otherType != 'int') {
              // if types are not equal, then
              int realIndex = i;
              if (idx != -1) {
                realIndex = idx - i;
              }
              String ambiguosTypePath = '$path[$realIndex]/$k';
              warnings.add(newAmbiguousType(ambiguosTypePath));
            }
          } else if (t == 'List') {
            List<dynamic> l = List<dynamic>.from(obj[k]);
            int beginIndex = l.length;
            l.addAll(v);
            // bug is here
            MergeableListType mergeableType = mergeableListType(l);
            if (ListType.Object == mergeableType.listType) {
              WithWarning<Map<dynamic, dynamic>> mergedList =
                  mergeObjectList(l, '$path[$i]/$k', beginIndex);
              warnings.addAll(mergedList.warnings);
              obj[k] = List<dynamic>.filled(1, mergedList.result);
            } else {
              if (l.length > 0) {
                obj[k] = List<dynamic>.filled(1, l[0]);
              }
              if (mergeableType.isAmbigous) {
                warnings.add(newAmbiguousType('$path[$i]/$k'));
              }
            }
          } else if (t == 'Class') {
            int properIndex = i;
            if (idx != -1) {
              properIndex = i - idx;
            }
            WithWarning<Map<dynamic, dynamic>> mergedObj = mergeObj(
              obj[k],
              v,
              '$path[$properIndex]/$k',
            );
            warnings.addAll(mergedObj.warnings);
            obj[k] = mergedObj.result;
          }
        }
      });
    }
  }
  return new WithWarning<Map<dynamic, dynamic>>(obj, warnings);
}

bool isPrimitiveType(String typeName) {
  bool isPrimitive = PRIMITIVE_TYPES[typeName];
  if (isPrimitive == null) {
    return false;
  }
  return isPrimitive;
}

String fixFieldName(String name,
    {TypeDefinition typeDef, bool privateField = false}) {
  String properName = name;
  if (name.startsWith('_') || name.startsWith(new RegExp(r'[0-9]'))) {
    String firstCharType = typeDef.name.substring(0, 1).toLowerCase();
    properName = '$firstCharType$name';
  }
  String fieldName = camelCaseFirstLower(properName);
  if (privateField) {
    return '_$fieldName';
  }
  return fieldName;
}

String getTypeName(dynamic obj) {
  if (obj is String) {
    return 'String';
  } else if (obj is int) {
    return 'int';
  } else if (obj is double) {
    return 'double';
  } else if (obj is bool) {
    return 'bool';
  } else if (obj == null) {
    return 'Null';
  } else if (obj is List) {
    return 'List';
  } else {
    // assumed class
    return 'Class';
  }
}

Node navigateNode(Node astNode, String path) {
  Node node;
  if (astNode is ObjectNode) {
    ObjectNode objectNode = astNode;
    PropertyNode propertyNode = objectNode.children.firstWhere(
        (PropertyNode prop) => prop.key.value == path,
        orElse: () => null);
    if (propertyNode != null) {
      node = propertyNode.value;
    }
  }
  if (astNode is ArrayNode) {
    ArrayNode arrayNode = astNode;
    int index = int.tryParse(path) ?? null;
    if (index != null && arrayNode.children.length > index) {
      node = arrayNode.children[index];
    }
  }
  return node;
}

final RegExp _pattern = RegExp(r'([0-9]+)\.{0,1}([0-9]*)e(([-0-9]+))');

bool isASTLiteralDouble(Node astNode) {
  if (astNode != null && astNode is LiteralNode) {
    LiteralNode literalNode = astNode;
    bool containsPoint = literalNode.raw.contains('.');
    bool containsExponent = literalNode.raw.contains('e');
    if (containsPoint || containsExponent) {
      bool isDouble = containsPoint;
      if (containsExponent) {
        RegExpMatch matches = _pattern.firstMatch(literalNode.raw);
        if (matches != null) {
          String integer = matches[1];
          String comma = matches[2];
          String exponent = matches[3];
          isDouble = _isDoubleWithExponential(integer, comma, exponent);
        }
      }
      return isDouble;
    }
  }
  return false;
}

bool _isDoubleWithExponential(String integer, String comma, String exponent) {
  int integerNumber = int.tryParse(integer) ?? 0;
  int exponentNumber = int.tryParse(exponent) ?? 0;
  int commaNumber = int.tryParse(comma) ?? 0;
  if (exponentNumber != null) {
    if (exponentNumber == 0) {
      return commaNumber > 0;
    }
    if (exponentNumber > 0) {
      return exponentNumber < comma.length && commaNumber > 0;
    }
    return commaNumber > 0 ||
        ((integerNumber.toDouble() * pow(10, exponentNumber)).remainder(1) > 0);
  }
  return false;
}
