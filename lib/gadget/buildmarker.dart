import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:latlong2/latlong.dart';

class MapPinLayer extends StatelessWidget {
  final List<Feature> features;

  const MapPinLayer(
    this.features,
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
            onTap: () => _openLamppostMarker(context, coor, feature.properties),
            child: const Icon(CustomIcon.lamp_street, size: 20, color: Colors.black),
          ),
        );
      })]
    );
  }

  void _openLamppostMarker(
    BuildContext context,
    List<double> coor,
    Properties properties
  ){
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${properties.Lamp_Post_Number} Info',
              style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold,)
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildCard('Lamp Post Number', properties.Lamp_Post_Number),
                  _buildCard('Latitude', properties.Latitude),
                  _buildCard('Longitude', properties.Longitude),
                  _buildCard('District', properties.District),
                  _buildCard('Location', properties.Location),
                ],
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, dynamic value){
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.toString()),
      ),
    );
  }
}