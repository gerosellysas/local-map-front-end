import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapViewer extends StatefulWidget {
  const MapViewer({Key? key}) : super(key: key);

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  MapController? _mapController;
  double south = -10.3599874813;
  double west = 95.2930261576;
  double north = 5.47982086834;
  double east = 141.03385176;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Map')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Text('Local Map Testing'),
            ),
            Flexible(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: const latlng.LatLng(-2.10221, 118.75290),
                  maxBounds: LatLngBounds(
                    latlng.LatLng(south, west),
                    latlng.LatLng(north, east),
                  ),
                  zoom: 4,
                  minZoom: 4,
                  maxZoom: 8,
                  swPanBoundary: latlng.LatLng(south, west),
                  nePanBoundary: latlng.LatLng(north, east),
                ),
                children: [
                  TileLayer(
                    urlTemplate: dotenv.env['SERVER']!,
                    subdomains: const ['a', 'b', 'c'],
                    tileBounds: LatLngBounds(
                      latlng.LatLng(south, west),
                      latlng.LatLng(north, east),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
