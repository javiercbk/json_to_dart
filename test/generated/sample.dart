class Sample {
  String username;
  int favouriteInteger;
  double favouriteDouble;
  String url;
  String htmlUrl;
  List<String> tags;
  List<int> randomIntegers;
  List<double> randomDoubles;
  PersonalInfo personalInfo;

  Sample(
      {this.username,
      this.favouriteInteger,
      this.favouriteDouble,
      this.url,
      this.htmlUrl,
      this.tags,
      this.randomIntegers,
      this.randomDoubles,
      this.personalInfo});

  Sample.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    favouriteInteger = json['favouriteInteger'];
    favouriteDouble = json['favouriteDouble'];
    url = json['url'];
    htmlUrl = json['html_url'];
    tags = json['tags'].cast<String>();
    randomIntegers = json['randomIntegers'].cast<int>();
    randomDoubles = json['randomDoubles'].cast<double>();
    personalInfo = json['personalInfo'] != null
        ? new PersonalInfo.fromJson(json['personalInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['favouriteInteger'] = this.favouriteInteger;
    data['favouriteDouble'] = this.favouriteDouble;
    data['url'] = this.url;
    data['html_url'] = this.htmlUrl;
    data['tags'] = this.tags;
    data['randomIntegers'] = this.randomIntegers;
    data['randomDoubles'] = this.randomDoubles;
    if (this.personalInfo != null) {
      data['personalInfo'] = this.personalInfo.toJson();
    }
    return data;
  }
}

class PersonalInfo {
  String firstName;
  String lastName;
  String location;
  List<Phones> phones;

  PersonalInfo({this.firstName, this.lastName, this.location, this.phones});

  PersonalInfo.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    location = json['location'];
    if (json['phones'] != null) {
      phones = new List<Phones>();
      json['phones'].forEach((v) {
        phones.add(new Phones.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['location'] = this.location;
    if (this.phones != null) {
      data['phones'] = this.phones.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Phones {
  String type;
  String number;
  bool shouldCall;

  Phones({this.type, this.number, this.shouldCall});

  Phones.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    number = json['number'];
    shouldCall = json['shouldCall'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['number'] = this.number;
    data['shouldCall'] = this.shouldCall;
    return data;
  }
}
