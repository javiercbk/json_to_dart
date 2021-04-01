class BugTen {

  BugTen({this.glossary});

  BugTen.fromJson(Map<String, dynamic> json) {
    glossary = json['glossary'] != null
        ? new Glossary.fromJson(json['glossary'])
        : null;
  }
  Glossary glossary;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.glossary != null) {
      data['glossary'] = this.glossary.toJson();
    }
    return data;
  }
}

class Glossary {

  Glossary({this.title, this.glossDiv});

  Glossary.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    glossDiv = json['GlossDiv'] != null
        ? new GlossDiv.fromJson(json['GlossDiv'])
        : null;
  }
  String title;
  GlossDiv glossDiv;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.glossDiv != null) {
      data['GlossDiv'] = this.glossDiv.toJson();
    }
    return data;
  }
}

class GlossDiv {

  GlossDiv({this.title, this.glossList});

  GlossDiv.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    glossList = json['GlossList'] != null
        ? new GlossList.fromJson(json['GlossList'])
        : null;
  }
  String title;
  GlossList glossList;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.glossList != null) {
      data['GlossList'] = this.glossList.toJson();
    }
    return data;
  }
}

class GlossList {

  GlossList({this.glossEntry});

  GlossList.fromJson(Map<String, dynamic> json) {
    glossEntry = json['GlossEntry'] != null
        ? new GlossEntry.fromJson(json['GlossEntry'])
        : null;
  }
  GlossEntry glossEntry;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.glossEntry != null) {
      data['GlossEntry'] = this.glossEntry.toJson();
    }
    return data;
  }
}

class GlossEntry {
  GlossEntry(
      {this.iD,
      this.sortAs,
      this.glossTerm,
      this.acronym,
      this.abbrev,
      this.glossDef,
      this.glossSee});

  GlossEntry.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    sortAs = json['SortAs'];
    glossTerm = json['GlossTerm'];
    acronym = json['Acronym'];
    abbrev = json['Abbrev'];
    glossDef = json['GlossDef'] != null
        ? new GlossDef.fromJson(json['GlossDef'])
        : null;
    glossSee = json['GlossSee'];
  }
  String iD;
  String sortAs;
  String glossTerm;
  String acronym;
  String abbrev;
  GlossDef glossDef;
  String glossSee;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['SortAs'] = this.sortAs;
    data['GlossTerm'] = this.glossTerm;
    data['Acronym'] = this.acronym;
    data['Abbrev'] = this.abbrev;
    if (this.glossDef != null) {
      data['GlossDef'] = this.glossDef.toJson();
    }
    data['GlossSee'] = this.glossSee;
    return data;
  }
}

class GlossDef {
  GlossDef({this.para, this.glossSeeAlso});

  GlossDef.fromJson(Map<String, dynamic> json) {
    para = json['para'];
    glossSeeAlso = json['GlossSeeAlso'].cast<String>();
  }
  String para;
  List<String> glossSeeAlso;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['para'] = this.para;
    data['GlossSeeAlso'] = this.glossSeeAlso;
    return data;
  }
}
