@JS()
library json_interop;

import 'package:js/js.dart';

@JS('JSON.stringify')
external String jsonStringify(Object obj, Function? replacer, int space);

@JS('JSON.parse')
external dynamic jsonParse(String json);
