import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hong_kong_geo_helper/mics/tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../assets/page_config.dart';

class MapTab extends StatelessWidget {
  const MapTab( {super.key} );

  @override
  Widget build(BuildContext context){
    return _buildMapTab(context);
  }

  Widget _buildMapTab(context){
    return Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(22.3193, 114.1694),
              initialZoom: 11.0,
            ),
            children: [
              openStreetMapTileLayer,
            ],
          )
        ],
      );
  }
}