import 'dart:convert';
import 'dart:core';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Case {
  DateTime date;
  int infections;
  int deaths;

  Case(this.date, this.infections, this.deaths);

}

Future initiate() async {
  Response response = await http.get("https://flevy.com/coronavirus/mexico");
  var document = parse(response.body);
  String text = document.querySelector("textarea").text;

  LineSplitter ls = new LineSplitter();
  List<String> lines = ls.convert(text);
  List<Case> cases = new List<Case>();
  for (String line in lines) {
    List<String> parsed = line.split('/t');
    DateTime date = DateTime.parse(parsed[1]);
    int infections = int.parse(parsed[1]);
    int deaths = int.parse(parsed[4]);
    cases.add(new Case(date,infections,deaths));
  }
}

main() {
 initiate();
}