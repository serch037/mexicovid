import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';

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

  Future<void> loadData() async {
    // data is from http://geojson.xyz/
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
