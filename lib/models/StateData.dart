import 'dart:core';

class StateData {
  int covidId;
  String covidName;
  String geoJsonName;
  int geoJSONId;
  int positiveCases;
  int negativeCases;
  int suspectCases;
  int deaths;

  StateData.fromJson(List<dynamic> json)
      : covidId = int.parse(json[0]),
        covidName = json[1].toString(),
        positiveCases = int.parse(json[4]),
        negativeCases = int.parse(json[5]),
        suspectCases = int.parse(json[6]),
        deaths = int.parse(json[7]);
}
