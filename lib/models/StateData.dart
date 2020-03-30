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

  StateData.fromJson(Map<String, dynamic> json)
      : covidId = json[0],
        covidName = json[1],
        positiveCases = json[4],
        negativeCases = json[5],
        suspectCases = json[6],
        deaths = json[7];
}
