import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

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
      _cases.add(new Case(date, infections, deaths));
    }

    List<charts.Series<Case, DateTime>> chart = [
      new charts.Series<Case, DateTime>(
        id: 'Desktop',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Case coCase, _) => coCase.date,
        measureFn: (Case coCase, _) => coCase.infections,
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
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              SizedBox(
                child: new charts.TimeSeriesChart(
                  snapshot.data,
                  animate: true,
                  dateTimeFactory: const charts.LocalDateTimeFactory(),
                ),
                width: 500,
                height: 500,
              )
            ];
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Center(
              child: Column(
            children: children,
          ));
        });
  }
}

class TimeSeriesChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TimeSeriesChartState();
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime timeCurrent;
  final DateTime timePrevious;
  final DateTime timeTarget;
  final int sales;

  TimeSeriesSales(
      {this.timeCurrent, this.timePrevious, this.timeTarget, this.sales});
}
