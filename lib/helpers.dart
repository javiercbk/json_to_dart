import 'dart:convert' as Convert;
import './syntax.dart';

const Map<String, bool> PRIMITIVE_TYPES = const {
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

String camelCase(String text) {
  String capitalize(Match m) => m[0].substring(0, 1).toUpperCase() + m[0].substring(1);
  String skip(String s) => "";
  return text.splitMapJoin(new RegExp(r'[a-zA-Z0-9]+'), onMatch: capitalize, onNonMatch: skip);
}

String camelCaseFirstLower(String text) {
  final camelCaseText = camelCase(text);
  final firstChar = camelCaseText.substring(0, 1).toLowerCase();
  final rest = camelCaseText.substring(1);
  return '$firstChar$rest';
}

decodeJSON(String rawJson) {
  return Convert.json.decode(rawJson);
}

WithWarning<Map> mergeObj(Map obj, Map other, String path) {
  List<Warning> warnings = new List<Warning>();
  final Map clone = Map.from(obj);
  other.forEach((k, v) {
    if (clone[k] == null) {
        clone[k] = v;
    } else {
      final String otherType = getTypeName(v);
      final String t = getTypeName(clone[k]);
      if (t != otherType) {
        if (t == 'int' && otherType == 'double') {
          // if double was found instead of int, assign the double
          clone[k] = v;
        } else if (clone[k].runtimeType != 'double' && v.runtimeType != 'int') {
          // if types are not equal, then 
          warnings.add(newAmbiguousType('$path/$k'));
        }
      } else if (t == 'List') {
        List l = List.from(clone[k]);
        l.addAll(other[k]);
        WithWarning<Map> mergedList = mergeList(l, '$path/$k');
        warnings.addAll(mergedList.warnings);
        clone[k] = List.filled(1, mergedList.result);
      } else if (t == 'Class') {
        WithWarning<Map> mergedObj = mergeObj(clone[k], other[k], '$path/$k');
        warnings.addAll(mergedObj.warnings);
        clone[k] = mergedObj.result;
      }
    }
  });
  return new WithWarning(clone, warnings);
}


WithWarning<Map> mergeList(List<dynamic> list, String path, [int idx = -1]) {
  List<Warning> warnings = new List<Warning>();
  Map obj = new Map();
  int beginIndex = 0;
  for(var i = 0; i < list.length; i++) {
    Map toMerge = list[i];
    toMerge.forEach((k, v) {
      final String t = getTypeName(obj[k]);
      if (obj[k] == null) {
        obj[k] = v;
      } else {
        final String otherType = getTypeName(v);
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
            final String ambiguosTypePath = '$path[$realIndex]/$k';
            warnings.add(newAmbiguousType(ambiguosTypePath));
          }
        } else if (t == 'List') {
          List l = List.from(obj[k]);
          final int beginIndex = l.length;
          l.addAll(v);
          WithWarning<Map> mergedList = mergeList(l, '$path[$i]/$k', beginIndex);
          warnings.addAll(mergedList.warnings);
          obj[k] = List.filled(1, mergedList.result);
        } else if (t == 'Class') {
          int properIndex = i;
          if (idx != -1) {
            properIndex = i - idx;
          }
          WithWarning<Map> mergedObj = mergeObj(obj[k], v, '$path[$properIndex]/$k',);
          warnings.addAll(mergedObj.warnings);
          obj[k] = mergedObj.result;
        }
      } 
    });
  }
  return new WithWarning(obj, warnings);
}

isPrimitiveType(String typeName) {
  final isPrimitive = PRIMITIVE_TYPES[typeName];
  if (isPrimitive == null) {
    return false;
  }
  return isPrimitive;
}

String fixFieldName(String name, { TypeDefinition typeDef, bool privateField = false }) {
  var properName = name;
  if (name.startsWith('_') || name.startsWith(new RegExp(r'[0-9]'))) {
    final firstCharType = typeDef.name.substring(0, 1).toLowerCase();
    properName = '$firstCharType$name';
  }
  final fieldName = camelCaseFirstLower(properName);
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