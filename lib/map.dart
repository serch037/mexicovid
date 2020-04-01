import 'package:covidmexico/models/StateData.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:http/http.dart' as http;


class MyMap extends StatefulWidget {
  @override
  MyMapState createState() => MyMapState();
}

class MyMapState extends State<MyMap> {
  MapController mapController;
  StatefulMapController statefulMapController;
  StreamSubscription<StatefulMapControllerStateChange> sub;
  final polygons = <Polygon>[];
  List<StateData> stateData;

  Color getColor(int cases) {
    if (cases < 50) {
      return Colors.lightGreen;
    } else if (cases < 100) {
      return Colors.green;
    } else if (cases < 250) {
      return Colors.amber;
    } else if (cases < 500) {
      return Colors.deepOrange;
    } else if (cases <= 1000) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  Future<void> getStateData() async {
    final response = await http.post(
      'http://ncov.sinave.gob.mx/Mapa45.aspx/Grafica23',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: "{}",
    );
    if (response.statusCode == 200) {
      var p1 = json.decode(response.body);
      print(p1);
      Iterable p2 = json.decode(p1["d"].toString());
      stateData = p2.map((var data) => StateData.fromJson(data)).toList();
      print(p2);
      //var p2 = json.decode(p1);
      //print(p2);
    }
  }

  Future<void> loadData() async {
    final geo = GeoJson();
    geo.processedFeatures.listen((GeoJsonFeature feature) {
      var stateId = int.parse(feature.properties["CODIGO"].toString().substring(2))-1;
      print(stateId);
      switch (feature.type) {
        case GeoJsonFeatureType.polygon:
          final poly = feature.geometry as GeoJsonPolygon;
          for (final geoSerie in poly.geoSeries) {
            setState(() => polygons.add(Polygon(
                borderStrokeWidth: 1,
                borderColor: Colors.white,
                color: getColor(stateData[stateId].positiveCases),
                points: geoSerie.toLatLng())));
          }
          break;
        case GeoJsonFeatureType.multipolygon:
          final mp = feature.geometry as GeoJsonMultiPolygon;
          for (final poly in mp.polygons) {
            for (final geoSerie in poly.geoSeries) {
              setState(() => polygons.add(Polygon(
                  borderStrokeWidth: 1,
                  borderColor: Colors.white,
                  color: getColor(stateData[stateId].positiveCases),
                  points: geoSerie.toLatLng())));
            }
          }
          break;
        default:
          break;
      }
    });
    print("Loading geojson data");
    final data = await rootBundle.loadString('assets/json/Mexico_Estados.json');
    //unawaited(geo.parse(data));
    await (geo.parse(data));
  }

  @override
  void initState() {
    mapController = MapController();
    getStateData().then((_) => setState(() {}));
    statefulMapController = StatefulMapController(mapController: mapController);
    statefulMapController.onReady.then((_) => loadData());
    sub = statefulMapController.changeFeed.listen((change) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(24.0, -102.0),
              zoom: 4.0,
            ),
            layers: [PolygonLayerOptions(polygons: polygons)],
          )),
    );
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}