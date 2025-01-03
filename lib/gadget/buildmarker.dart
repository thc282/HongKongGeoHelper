import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:latlong2/latlong.dart';

class MapPinLayer extends StatelessWidget {
  final List<Feature> features;
  final IconData icon;
  final Function(Feature) onTapCallback;

  const MapPinLayer(
    this.features,
    this.icon,
    this.onTapCallback,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [...features.map((feature){
        final coor = feature.geometry.coordinates;
        return Marker(
          point: LatLng(coor[1], coor[0]),
          child: GestureDetector(
            onTap: () => onTapCallback(feature), //_openLamppostMarker(context, coor, feature.properties),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
        );
      })]
    );
  }
}