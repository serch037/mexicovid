import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'models/TimeData.dart';

class TimeSeriesChartState extends State<TimeSeriesChart> {
  Future<List<charts.Series<Case, DateTime>>> initiate() async {
    Response response = await http.get("https://flevy.com/coronavirus/mexico");
    var document = parse(response.body);
    String text = document.querySelector("textarea").text;

    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(text);
    List<Case> _cases = new List<Case>();
    for (var i = 1; i < lines.length; i++) {
      String line = lines[i];
      List<String> parsed = line.split('\t');
      DateTime date = DateTime.parse(parsed[0]);
      int infections = int.parse(parsed[1]);
      int deaths = int.parse(parsed[4]);
      int recovered = int.parse(parsed[7]);
      _cases.add(new Case(date, infections, deaths, recovered));
    }

    List<charts.Series<Case, DateTime>> chart = [
      new charts.Series<Case, DateTime>(
        id: 'Infections',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Case coCase, _) => coCase.date,
        measureFn: (Case coCase, _) => coCase.infections,
        data: _cases,
      ),
      new charts.Series<Case, DateTime>(
        id: 'Deaths',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (Case coCase, _) => coCase.date,
        measureFn: (Case coCase, _) => coCase.deaths,
        data: _cases,
      ),
      new charts.Series<Case, DateTime>(
        id: 'Recovered',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (Case coCase, _) => coCase.date,
        measureFn: (Case coCase, _) => coCase.recovered,
        data: _cases,
      ),
    ];
    return chart;
  }

  @override
  void initState() {
    initiate().then((_) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return testWidget();
  }

  Widget testWidget() {
    return FutureBuilder<List<charts.Series>>(
        future: initiate(),
        builder: (BuildContext context,
            AsyncSnapshot<List<charts.Series>> snapshot) {
          if (snapshot.hasData) {
            return SizedBox(
              child: new charts.TimeSeriesChart(
                snapshot.data,
                animate: true,
                dateTimeFactory: const charts.LocalDateTimeFactory(),
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 4 * 3,
            );
          } else {
            return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Awaiting result...')
                  ],
                )
            );
          }
        });
  }
}

class TimeSeriesChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TimeSeriesChartState();
}
