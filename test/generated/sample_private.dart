class Sample {
  String _username;
  int _favouriteInteger;
  double _favouriteDouble;
  String _url;
  String _htmlUrl;
  List<String> _tags;
  List<int> _randomIntegers;
  List<double> _randomDoubles;
  PersonalInfo _personalInfo;

  Sample(
      {String username,
      int favouriteInteger,
      double favouriteDouble,
      String url,
      String htmlUrl,
      List<String> tags,
      List<int> randomIntegers,
      List<double> randomDoubles,
      PersonalInfo personalInfo}) {
    this._username = username;
    this._favouriteInteger = favouriteInteger;
    this._favouriteDouble = favouriteDouble;
    this._url = url;
    this._htmlUrl = htmlUrl;
    this._tags = tags;
    this._randomIntegers = randomIntegers;
    this._randomDoubles = randomDoubles;
    this._personalInfo = personalInfo;
  }

  String get username => _username;
  set username(String username) => _username = username;
  int get favouriteInteger => _favouriteInteger;
  set favouriteInteger(int favouriteInteger) =>
      _favouriteInteger = favouriteInteger;
  double get favouriteDouble => _favouriteDouble;
  set favouriteDouble(double favouriteDouble) =>
      _favouriteDouble = favouriteDouble;
  String get url => _url;
  set url(String url) => _url = url;
  String get htmlUrl => _htmlUrl;
  set htmlUrl(String htmlUrl) => _htmlUrl = htmlUrl;
  List<String> get tags => _tags;
  set tags(List<String> tags) => _tags = tags;
  List<int> get randomIntegers => _randomIntegers;
  set randomIntegers(List<int> randomIntegers) =>
      _randomIntegers = randomIntegers;
  List<double> get randomDoubles => _randomDoubles;
  set randomDoubles(List<double> randomDoubles) =>
      _randomDoubles = randomDoubles;
  PersonalInfo get personalInfo => _personalInfo;
  set personalInfo(PersonalInfo personalInfo) => _personalInfo = personalInfo;

  Sample.fromJson(Map<String, dynamic> json) {
    _username = json['username'];
    _favouriteInteger = json['favouriteInteger'];
    _favouriteDouble = json['favouriteDouble'];
    _url = json['url'];
    _htmlUrl = json['html_url'];
    _tags = json['tags'].cast<String>();
    _randomIntegers = json['randomIntegers'].cast<int>();
    _randomDoubles = json['randomDoubles'].cast<double>();
    _personalInfo = json['personalInfo'] != null
        ? new PersonalInfo.fromJson(json['personalInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this._username;
    data['favouriteInteger'] = this._favouriteInteger;
    data['favouriteDouble'] = this._favouriteDouble;
    data['url'] = this._url;
    data['html_url'] = this._htmlUrl;
    data['tags'] = this._tags;
    data['randomIntegers'] = this._randomIntegers;
    data['randomDoubles'] = this._randomDoubles;
    if (this._personalInfo != null) {
      data['personalInfo'] = this._personalInfo.toJson();
    }
    return data;
  }
}

class PersonalInfo {
  String _firstName;
  String _lastName;
  String _location;
  List<Phones> _phones;

  PersonalInfo(
      {String firstName,
      String lastName,
      String location,
      List<Phones> phones}) {
    this._firstName = firstName;
    this._lastName = lastName;
    this._location = location;
    this._phones = phones;
  }

  String get firstName => _firstName;
  set firstName(String firstName) => _firstName = firstName;
  String get lastName => _lastName;
  set lastName(String lastName) => _lastName = lastName;
  String get location => _location;
  set location(String location) => _location = location;
  List<Phones> get phones => _phones;
  set phones(List<Phones> phones) => _phones = phones;

  PersonalInfo.fromJson(Map<String, dynamic> json) {
    _firstName = json['firstName'];
    _lastName = json['lastName'];
    _location = json['location'];
    if (json['phones'] != null) {
      _phones = new List<Phones>();
      json['phones'].forEach((v) {
        _phones.add(new Phones.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this._firstName;
    data['lastName'] = this._lastName;
    data['location'] = this._location;
    if (this._phones != null) {
      data['phones'] = this._phones.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Phones {
  String _type;
  String _number;
  bool _shouldCall;

  Phones({String type, String number, bool shouldCall}) {
    this._type = type;
    this._number = number;
    this._shouldCall = shouldCall;
  }

  String get type => _type;
  set type(String type) => _type = type;
  String get number => _number;
  set number(String number) => _number = number;
  bool get shouldCall => _shouldCall;
  set shouldCall(bool shouldCall) => _shouldCall = shouldCall;

  Phones.fromJson(Map<String, dynamic> json) {
    _type = json['type'];
    _number = json['number'];
    _shouldCall = json['shouldCall'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this._type;
    data['number'] = this._number;
    data['shouldCall'] = this._shouldCall;
    return data;
  }
}
