import 'dart:io';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:json_to_dart/json_to_dart.dart' show ModelGenerator;
import './generated/bug_ten.dart';

void main() {
  group("model-generator", () {
    test("Should generate the classes to parse the JSON", () {
      final jsonRawData =
          new File("test_resources/bug_10.json").readAsStringSync();
      final generator = ModelGenerator('BugTen');
      final dartCode = generator.generateDartClasses(jsonRawData);
      expect(dartCode.warnings.length, equals(0));
      expect(dartCode.code.contains('class GlossDiv'), equals(true));
    });

    test("Generated class should correctly parse JSON for bug 10", () {
      final jsonRawData =
          new File("test_resources/bug_10.json").readAsStringSync();
      Map<String, dynamic> sampleMap = json.decode(jsonRawData);
      final bugTen = new BugTen.fromJson(sampleMap);
      expect(bugTen, isNot(isNull));
      expect(bugTen.glossary, isNot(isNull));
      expect(bugTen.glossary!.title, equals('example glossary'));
      expect(bugTen.glossary!.glossDiv, isNot(isNull));
      expect(bugTen.glossary!.glossDiv!.title, equals("S"));
      expect(bugTen.glossary!.glossDiv!.glossList, isNot(isNull));
      final ge = bugTen.glossary!.glossDiv!.glossList!.glossEntry;
      expect(ge, isNot(isNull));
      expect(ge!.iD, equals("SGML"));
      expect(ge.sortAs, equals("SGML"));
      expect(ge.glossTerm, equals("Standard Generalized Markup Language"));
      expect(ge.acronym, equals("SGML"));
      expect(ge.abbrev, equals("ISO 8879:1986"));
      expect(ge.glossSee, equals("markup"));
      expect(ge.glossDef, isNot(isNull));
      expect(
          ge.glossDef!.para,
          equals(
              "A meta-markup language, used to create markup languages such as DocBook."));
      final seeAlso = ge.glossDef!.glossSeeAlso;
      expect(seeAlso, isNot(isNull));
      expect(seeAlso!.length, equals(2));
      expect(seeAlso[0], equals("GML"));
      expect(seeAlso[1], equals("XML"));
    });

    test("Generated class should correctly generate JSON", () {
      final glossSeeAlso = <String>[];
      glossSeeAlso.add("GML");
      glossSeeAlso.add("XML");
      final glossDef = new GlossDef(
          para:
              "A meta-markup language, used to create markup languages such as DocBook.",
          glossSeeAlso: glossSeeAlso);
      final glossEntry = new GlossEntry(
        abbrev: "ISO 8879:1986",
        acronym: "SGML",
        glossDef: glossDef,
        glossSee: "markup",
        glossTerm: "Standard Generalized Markup Language",
        iD: "SGML",
        sortAs: "SGML",
      );
      final glossList = new GlossList(
        glossEntry: glossEntry,
      );
      final glossDiv = new GlossDiv(
        glossList: glossList,
        title: "S",
      );
      final glossary = new Glossary(
        glossDiv: glossDiv,
        title: "example glossary",
      );
      final bugTen = new BugTen(glossary: glossary);
      final codec = new JsonCodec(toEncodable: (dynamic v) => v.toString());
      final encodedJSON = codec.encode(bugTen.toJson());
      expect(encodedJSON.contains('"title":"example glossary"'), equals(true));
      expect(encodedJSON.contains('"GlossDiv":{"title":"S"'), equals(true));
      expect(encodedJSON.contains('"GlossList":{"GlossEntry":{'), equals(true));
      expect(encodedJSON.contains('"ID":"SGML",'), equals(true));
      expect(encodedJSON.contains('"SortAs":"SGML",'), equals(true));
      expect(
          encodedJSON
              .contains('"GlossTerm":"Standard Generalized Markup Language",'),
          equals(true));
      expect(encodedJSON.contains('"Acronym":"SGML",'), equals(true));
      expect(encodedJSON.contains('"Abbrev":"ISO 8879:1986",'), equals(true));
      expect(
          encodedJSON.contains(
              '"GlossDef":{"para":"A meta-markup language, used to create markup languages such as DocBook.",'),
          equals(true));
      expect(
          encodedJSON.contains('"GlossSeeAlso":["GML","XML"]'), equals(true));
      expect(encodedJSON.contains('"GlossSee":"markup"'), equals(true));
    });
  });
}
