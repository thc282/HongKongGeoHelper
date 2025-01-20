import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:hong_kong_geo_helper/mics/LocationSearchProvider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

//Lamppost Search Page
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

/*=========================
 *  Location Search Page
 * ========================
 */
class markerClusterLayer extends StatelessWidget {
  final PopupController popupController;
  
  const markerClusterLayer(this.popupController, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    late LocationSearchInfo onSelectedMarker;

    return Consumer<LocationSearchProvider>(
      builder: (context, provider, child){
        markers = provider.searchResult.map((result) {
          var latlng = Converter.convert.gridToLatLng(Coordinate(x:result.x, y:result.y));
          return Marker(
            point: LatLng(latlng.lat, latlng.lng),
            child: const Icon(Icons.location_on, size: 20, color: Colors.red)
          );
        }).toList();
        return MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            maxZoom: 15,
            disableClusteringAtZoom: 17,
            markers: markers,
            onMarkerTap: (_onSelectedMarker){
              onSelectedMarker = 
              provider.searchResult.firstWhere(
                (element) {
                  var latlng = Converter.convert.gridToLatLng(Coordinate(x:element.x, y:element.y));
                  return LatLng(latlng.lat, latlng.lng) == _onSelectedMarker.point;
                }
              );
            },
            builder: (context, markers) {
              return Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    markers.length <= 10 ? markers.length.toString() : "10+",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            },
            popupOptions: PopupOptions(
              popupController: popupController,
              popupAnimation: const PopupAnimation.fade(),
              markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
              popupBuilder: (context, marker) => _buildLandInfoCard(context, onSelectedMarker, marker.point),
            ),
          ),
        );
      }
    );
  }
}

Widget _buildLandInfoCard(context, LocationSearchInfo properties, LatLng point){
  return Container(
    width: MediaQuery.of(context).size.width * 0.8,
    height: MediaQuery.of(context).size.height * 0.2,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black54),
    child: Expanded(
      child: ListView(
        children: [
          _buildCard('地址', properties.addressZH),
          _buildCard('建築名稱', properties.nameZH),
          _buildCard('地區', properties.districtZH),
          const Divider(),
          _buildCard('Address', properties.addressEN),
          _buildCard('Building Name', properties.nameEN),
          _buildCard('District', properties.districtEN),
          const Divider(),
          _buildCard('座標', '${point.latitude}, ${point.longitude}'),
        ],
      )
    )
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