import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const OsmMapApp());
}

class OsmMapApp extends StatelessWidget {
  const OsmMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OSM Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MapHomePage(),
    );
  }
}

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  static const LatLng _defaultCenter = LatLng(39.9042, 116.4074); // Beijing

  final MapController _mapController = MapController();

  double _currentZoom = 13;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap 首页'),
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _defaultCenter,
          initialZoom: _currentZoom,
          onMapEvent: (event) {
            if (event is MapEventMoveEnd || event is MapEventRotateEnd) {
              setState(() {
                _currentZoom = _mapController.camera.zoom;
              });
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_osm_map',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(
            markers: const [
              Marker(
                width: 80,
                height: 80,
                point: _defaultCenter,
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 36,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _MapFab(
            icon: Icons.zoom_in,
            onPressed: () {
              final double zoom = (_mapController.camera.zoom + 1).clamp(1, 19);
              _mapController.move(_mapController.camera.center, zoom);
            },
            tooltip: '放大',
          ),
          const SizedBox(height: 12),
          _MapFab(
            icon: Icons.zoom_out,
            onPressed: () {
              final double zoom = (_mapController.camera.zoom - 1).clamp(1, 19);
              _mapController.move(_mapController.camera.center, zoom);
            },
            tooltip: '缩小',
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black26,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Text(
              'Zoom: ${_currentZoom.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: tooltip,
      onPressed: onPressed,
      tooltip: tooltip,
      shape: const CircleBorder(),
      child: Icon(icon),
    );
  }
}
