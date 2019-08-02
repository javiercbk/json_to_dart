@JS()
library ace_interop;

import 'dart:html';
import 'package:js/js.dart';

@JS()
external ACEInterface get ace;

@JS()
class ACEInterface {
  external ACEEditor edit(Element el);
  external dynamic require(String moduleName);
}

@JS()
@anonymous
class ACEEditor {

  external void on(String eventName, Function);
  external String getValue();
  external ACEEditorSession getSession();
  external void setTheme(String theme);
  external void setValue(String text);
}

@JS()
@anonymous
class ACEEditorSession {
  external void clearAnnotations();
  external void setAnnotations(List<ACEEditorAnnotation> annotations);
  external void setMode(String mode);
  external void setOption(String optionName, dynamic value);
}

@JS()
@anonymous
class ACEEditorAnnotation {
  external int get row;
  external set row(int _row);
  external int get column;
  external set column(int _column);
  external String get text;
  external set text(String _text);
  external String get type;
  external set type(String _type);
}