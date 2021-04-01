import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' show dirname, join, normalize;
import 'package:test/test.dart';
import './generated/sample_private.dart';

String _scriptPath() {
  String script = Platform.script.toString();
  if (script.startsWith('file://')) {
    script = script.substring(7);
  } else {
    int idx = script.indexOf('file:/');
    script = script.substring(idx + 5);
  }
  return script;
}

void main() {
  group('model-generator', () {
    String currentDirectory = dirname(_scriptPath());
    test('Generated class with private fields should correctly parse JSON', () {
      String jsonPath = normalize(join(currentDirectory, 'test.json'));
      String jsonRawData = new File(jsonPath).readAsStringSync();
      Map<dynamic, dynamic> sampleMap = json.decode(jsonRawData);
      Sample sample = new Sample.fromJson(sampleMap);
      expect(sample, isNot(isNull));
      expect(sample.username, equals('javiercbk'));
      expect(sample.favouriteInteger, equals(18));
      expect(sample.favouriteDouble, equals(1.6180));
      expect(sample.url, equals('https://api.github.com/users/javiercbk'));
      expect(sample.htmlUrl, equals('https://github.com/javiercbk'));
      expect(sample.tags, isNot(isNull));
      expect(sample.tags.length, equals(3));
      expect(sample.tags[0], equals('dart'));
      expect(sample.tags[1], equals('json'));
      expect(sample.tags[2], equals('cool'));
      expect(sample.randomIntegers, isNot(isNull));
      expect(sample.randomIntegers.length, equals(3));
      expect(sample.randomIntegers[0], equals(1));
      expect(sample.randomIntegers[1], equals(2));
      expect(sample.randomIntegers[2], equals(3));
      expect(sample.randomDoubles, isNot(isNull));
      expect(sample.randomDoubles.length, equals(3));
      expect(sample.randomDoubles[0], equals(1.1));
      expect(sample.randomDoubles[1], equals(2.2));
      expect(sample.randomDoubles[2], equals(3.3));
      PersonalInfo pi = sample.personalInfo;
      expect(pi, isNot(isNull));
      expect(pi.firstName, equals('Javier'));
      expect(pi.lastName, equals('Lecuona'));
      expect(pi.location, equals('Buenos Aires, Argentina'));
      List<Phones> ph = pi.phones;
      expect(ph, isNot(isNull));
      expect(ph.length, equals(2));
      expect(ph[0], isNot(isNull));
      expect(ph[0].type, equals('work'));
      expect(ph[0].number, equals('123-this-is-a-fake-phone'));
      expect(ph[0].shouldCall, equals(false));
      expect(ph[1], isNot(isNull));
      expect(ph[1].type, equals('home'));
      expect(ph[1].number, equals('123-this-is-a-phony-phone'));
      expect(ph[1].shouldCall, equals(false));
    });

    test('''
Generated class with private fields should correctly parse JSON with missing values''',
        () {
      String jsonPath = normalize(join(currentDirectory, 'test_missing.json'));
      String jsonRawData = new File(jsonPath).readAsStringSync();
      Map<dynamic, dynamic> sampleMap = json.decode(jsonRawData);
      Sample sample = new Sample.fromJson(sampleMap);
      expect(sample, isNot(isNull));
      expect(sample.username, equals('javiercbk'));
      expect(sample.favouriteInteger, isNull);
      expect(sample.favouriteDouble, equals(1.6180));
      expect(sample.url, equals('https://api.github.com/users/javiercbk'));
      expect(sample.htmlUrl, isNull);
      expect(sample.tags, isNot(isNull));
      expect(sample.tags.length, equals(3));
      expect(sample.tags[0], equals('dart'));
      expect(sample.tags[1], equals('json'));
      expect(sample.tags[2], equals('cool'));
      expect(sample.randomIntegers, isNot(isNull));
      expect(sample.randomIntegers.length, equals(3));
      expect(sample.randomIntegers[0], equals(1));
      expect(sample.randomIntegers[1], equals(2));
      expect(sample.randomIntegers[2], equals(3));
      expect(sample.randomDoubles, isNot(isNull));
      expect(sample.randomDoubles.length, equals(3));
      expect(sample.randomDoubles[0], equals(1.1));
      expect(sample.randomDoubles[1], equals(2.2));
      expect(sample.randomDoubles[2], equals(3.3));
      PersonalInfo pi = sample.personalInfo;
      expect(pi, isNot(isNull));
      expect(pi.firstName, equals('Javier'));
      expect(pi.lastName, isNull);
      expect(pi.location, isNull);
      expect(pi.phones, isNull);
    });

    test('Generated class with private fields should correctly generate JSON',
        () {
      List<Phones> phones = <Phones>[];
      Phones phone = new Phones(
        type: 'IP',
        number: '127.0.0.1',
        shouldCall: true,
      );
      phones.add(phone);
      PersonalInfo personalInfo = new PersonalInfo(
        firstName: 'User',
        lastName: 'Test',
        location: 'In a computer',
        phones: phones,
      );
      Sample sample = new Sample(
        username: 'Test',
        favouriteInteger: 13,
        favouriteDouble: 3.1416,
        url: 'http://test.test',
        htmlUrl: 'http://anothertest.test',
        tags: <String>['test1'],
        randomIntegers: <int>[4, 5],
        randomDoubles: <double>[4.4, 5.5],
        personalInfo: personalInfo,
      );
      JsonCodec codec = new JsonCodec(toEncodable: (dynamic v) => v.toString());
      String encodedJSON = codec.encode(sample.toJson());
      expect(encodedJSON.contains('"username":"Test"'), equals(true));
      expect(encodedJSON.contains('"favouriteInteger":13'), equals(true));
      expect(encodedJSON.contains('"favouriteDouble":3.1416'), equals(true));
      expect(encodedJSON.contains('"url":"http://test.test"'), equals(true));
      expect(encodedJSON.contains('"html_url":"http://anothertest.test"'),
          equals(true));
      expect(encodedJSON.contains('"tags":["test1"]'), equals(true));
      expect(encodedJSON.contains('"randomIntegers":[4,5]'), equals(true));
      expect(encodedJSON.contains('"randomDoubles":[4.4,5.5]'), equals(true));
      expect(encodedJSON.contains('"personalInfo":{'), equals(true));
      expect(encodedJSON.contains('"firstName":"User"'), equals(true));
      expect(encodedJSON.contains('"lastName":"Test"'), equals(true));
      expect(encodedJSON.contains('"location":"In a computer"'), equals(true));
      expect(encodedJSON.contains('"phones":['), equals(true));
      expect(encodedJSON.contains('"type":"IP"'), equals(true));
      expect(encodedJSON.contains('"number":"127.0.0.1"'), equals(true));
      expect(encodedJSON.contains('"shouldCall":true'), equals(true));
    });

    test('''
Generated class with private fields should correctly generate JSON with missing values''',
        () {
      PersonalInfo personalInfo = new PersonalInfo(
        firstName: 'User',
        lastName: null,
      );
      Sample sample = new Sample(
        username: 'Test',
        favouriteInteger: null,
        favouriteDouble: 3.1416,
        url: 'http://test.test',
        tags: <String>['test1'],
        randomIntegers: <int>[4, 5],
        randomDoubles: <double>[4.4, 5.5],
        personalInfo: personalInfo,
      );
      JsonCodec codec = new JsonCodec(toEncodable: (dynamic v) => v.toString());
      String encodedJSON = codec.encode(sample.toJson());
      expect(encodedJSON.contains('"username":"Test"'), equals(true));
      expect(encodedJSON.contains('"favouriteInteger":null'), equals(true));
      expect(encodedJSON.contains('"favouriteDouble":3.1416'), equals(true));
      expect(encodedJSON.contains('"url":"http://test.test"'), equals(true));
      expect(encodedJSON.contains('"html_url":null'), equals(true));
      expect(encodedJSON.contains('"tags":["test1"]'), equals(true));
      expect(encodedJSON.contains('"randomIntegers":[4,5]'), equals(true));
      expect(encodedJSON.contains('"randomDoubles":[4.4,5.5]'), equals(true));
      expect(encodedJSON.contains('"personalInfo":{'), equals(true));
      expect(encodedJSON.contains('"firstName":"User"'), equals(true));
      expect(encodedJSON.contains('"lastName":null'), equals(true));
      expect(encodedJSON.contains('"location":null'), equals(true));
      expect(encodedJSON.contains('"phones"'), equals(false));
    });
  });
}
