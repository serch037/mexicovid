import 'dart:convert';

import 'package:covidmexico/models/StateData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class ListStatesState extends State<ListStates> {
  final image_base_url =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Coat_of_arms_of_";

  String buildImageUrl(String stateName) {
    //https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Coat_of_arms_of_Aguascalientes.svg/100px-Coat_of_arms_of_Aguascalientes.svg.png
    var parsedState = stateName
        .replaceAll(" ", "_")
        .replaceAll("á", "a")
        .replaceAll("é", "e")
        .replaceAll("í", "i")
        .replaceAll("ó", "o")
        .replaceAll("ú", "u");
    return "${image_base_url}${parsedState}.svg/100px-Coat_of_arms_of_${parsedState}.svg.png";
  }

  Widget _StateTile(StateData state) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
              backgroundImage: NetworkImage(buildImageUrl(state.covidName)),
              child: Text(state.covidName[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
          title: Text(state.covidName),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StatePage(
                          stateData: state,
                          coatUrl: buildImageUrl(state.covidName),
                        )));
          },
        ));
  }

  Future getStateData() async {
    final response = await http.post(
      'http://ncov.sinave.gob.mx/Mapa45.aspx/Grafica23',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: "{}",
    );
    List<StateData> stateData = new List();
    if (response.statusCode == 200) {
      var p1 = json.decode(response.body);
      print(p1);
      Iterable p2 = json.decode(p1["d"].toString());
      stateData = p2.map((var data) => StateData.fromJson(data)).toList();
    }
    return stateData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  StateData state = snapshot.data[index];
                  return Column(
                    children: <Widget>[_StateTile(state)],
                  );
                });
          } else {
            return Container(
              child: Text('Loading'),
            );
          }
        },
        future: getStateData());
  }
}

class ListStates extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListStatesState();
  }
}

class StatePage extends StatelessWidget {
  final StateData stateData;
  final String coatUrl;

  const StatePage({Key key, this.stateData, this.coatUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('COVID-19 México'),
        ),
        body: Container(
            child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(coatUrl), fit: BoxFit.cover)),
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 3,
            ),
            ListTile(
              leading: Text('Estado'),
              title: Text(stateData.covidName),
            ),
            ListTile(
              leading: Text('Infectados'),
              title: Text(stateData.positiveCases.toString()),
            ),
            ListTile(
              leading: Text('Defunciones'),
              title: Text(stateData.deaths.toString()),
            ),
//        ListTile(
//          leading: Text('Recuperados'),
//          title: Text(stateData.recovered.toString()),
//        ),
//        ListTile(
//          leading: Text('Población'),
//          title: Text(stateData.population.toString()),
//        ),
          ],
        )));
  }
}
