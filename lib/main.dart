import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMap(),
    );
  }
}

class MyMap extends StatefulWidget {
  @override
  MyMapState createState() => MyMapState();
}

class MyMapState extends State<MyMap> {
  MapController mapController;
  StatefulMapController statefulMapController;
  StreamSubscription<StatefulMapControllerStateChange> sub;
  final polygons = <Polygon>[];

  Future<http.Response> getCovidData() {
    return http.post(
      'http://ncov.sinave.gob.mx/Mapa45.aspx/Grafica23',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: "{}",
    );
  }

  Future<void> loadData() async {
    final geo = GeoJson();
    geo.processedFeatures.listen((GeoJsonFeature feature) {
      switch (feature.type) {
        case GeoJsonFeatureType.polygon:
          final poly = feature.geometry as GeoJsonPolygon;
          for (final geoSerie in poly.geoSeries) {
            setState(() => polygons
                .add(Polygon(color: Colors.blue, points: geoSerie.toLatLng())));
          }
          break;
        case GeoJsonFeatureType.multipolygon:
          final mp = feature.geometry as GeoJsonMultiPolygon;
          for (final poly in mp.polygons) {
            for (final geoSerie in poly.geoSeries) {
              setState(() => polygons.add(
                  Polygon(color: Colors.blue, points: geoSerie.toLatLng())));
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
    await(geo.parse(data));
    http.Response test  = await getCovidData();
    if(test.statusCode == 200) {
      var p1 = json.decode(test.body);
      print(p1);
      var p2 = json.decode(p1["d"].toString());
      print(p2);
      //var p2 = json.decode(p1);
      //print(p2);
    }
  }

  @override
  void initState() {
    mapController = MapController();
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
        layers: [
          PolygonLayerOptions(polygons: polygons)
        ],
      )),
    );
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}
