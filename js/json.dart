@JS()
library json_interop;

import 'package:js/js.dart';

@JS()
external JSONInterface get JSON;

@JS()
class JSONInterface {
  external String stringify(dynamic value, Function replacer, int space);
  external dynamic parse(String json);
}