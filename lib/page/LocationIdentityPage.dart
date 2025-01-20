import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:hong_kong_geo_helper/gadget/MarkerControl.dart';
import 'package:hong_kong_geo_helper/mics/LocationIdentifyProvider.dart';
import 'package:hong_kong_geo_helper/mics/tile_provider.dart';
import 'package:latlong2/latlong.dart';

class LocationIdentityTab extends StatefulWidget {
  const LocationIdentityTab({super.key});

  @override
  State<LocationIdentityTab> createState() => _LocationIdentityTabState();
}

class _LocationIdentityTabState extends State<LocationIdentityTab> {
  final mapController = MapController();
  final _popupController = PopupController();
  
  @override
  Widget build(BuildContext context) {
    Locationidentifyprovider.testFetch();
    return Stack(
      children: [
        PopupScope(
          popupController: _popupController,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: (_,__) => _popupController.hideAllPopups(),
              initialCenter: const LatLng(22.3193, 114.1694),
            ),
            children: [
              openStreetMapTileLayer,
              openStreetMapLabelTileLayer,
              markerClusterLayer(_popupController),
            ],
          ),
        ),
      ],
    );
  }
}