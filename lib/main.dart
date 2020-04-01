import 'package:covidmexico/charts.dart';
import 'package:covidmexico/map.dart';
import 'package:covidmexico/states.dart';

import 'package:flutter/material.dart';

void main() => runApp(MyRoot());
class MyRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MexicoVid',
      theme : ThemeData(
        primarySwatch: Colors.blue
      ),
      home: MyApp()
    );
  }

}

class MyAppState extends State<MyApp> {
  int _selectedTab = 0;
  final _pageOptions = [
    MyMap(),
    ListStates(),
    TimeSeriesChart(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('COVID-19 México'),
        ),
        body: _pageOptions[_selectedTab],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (int index) {
            setState(() {
              _selectedTab = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              title: Text('Mapa'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list),
              title: Text('Estados'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              title: Text('Gráfica'),
            ),
          ],
        ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }

}


