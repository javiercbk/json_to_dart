import 'dart:convert' as Convert;
import './syntax.dart';

const Map<String, bool> PRIMITIVE_TYPES = const {
  'int': true,
  'double': true,
  'String': true,
  'bool': true,
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