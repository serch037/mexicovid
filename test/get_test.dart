import 'dart:convert';

import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class Case {
  DateTime date;
  int infections;
  int deaths;

  Case(this.date, this.infections, this.deaths);
}

Future<List<Case>> initiate() async {
  Response response = await http.get("https://flevy.com/coronavirus/mexico");
  var document = parse(response.body);
  String text = document.querySelector("textarea").text;

  LineSplitter ls = new LineSplitter();
  List<String> lines = ls.convert(text);
  List<Case> cases = new List<Case>();
  for (var i = 1; i < lines.length; i++) {
    String line = lines[i];
    List<String> parsed = line.split('\t');
    DateTime date = DateTime.parse(parsed[0]);
    int infections = int.parse(parsed[1]);
    int deaths = int.parse(parsed[4]);
    cases.add(new Case(date, infections, deaths));
  }
  return cases;
}

main() async {
  var cases = await initiate();
  print(cases);
}
