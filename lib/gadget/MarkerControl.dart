import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:hong_kong_geo_helper/mics/LocationSearchProvider.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

//Lamppost Search Page
/*class MapPinLayer extends StatelessWidget {
  final List<Feature> features;
  final IconData icon;
  final Function(Feature) onTapCallback;

  const MapPinLayer(this.features, this.icon, this.onTapCallback, {super.key});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(markers: [
      ...features.map((feature) {
        final coor = feature.geometry.coordinates;
        return Marker(
          point: LatLng(coor[1], coor[0]),
          child: GestureDetector(
            onTap: () => onTapCallback(
                feature), //_openLamppostMarker(context, coor, feature.properties),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
        );
      })
    ]);
  }
}*/

class MarkerWithData {
  final Marker marker;
  final dynamic data;

  MarkerWithData(this.marker, this.data);
}

/*=========================
 *  Location Search Page
 * ========================
 */
class markerClusterLayer<T extends ChangeNotifier> extends StatelessWidget {
  final PopupController popupController;
  final T provider;
  final List<MarkerWithData> Function(T provider) markerBuilder;

  const markerClusterLayer(
      this.popupController, this.provider, this.markerBuilder,
      {super.key});

  @override
  Widget build(BuildContext context) {
    List<MarkerWithData> markersWithData = [];
    dynamic onSelectedMarkerData;

    return Consumer<T>(builder: (context, provider, child) {
      markersWithData = markerBuilder(provider);
      return MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          maxClusterRadius: 45,
          size: const Size(40, 40),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(50),
          maxZoom: 15,
          disableClusteringAtZoom: 17,
          markers: markersWithData.map((m) => m.marker).toList(),
          onMarkerTap: (onSelectedMarker) {
            onSelectedMarkerData = markersWithData
                .firstWhere((m) => m.marker == onSelectedMarker)
                .data;
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
              popupBuilder: (context, marker) {
                switch (onSelectedMarkerData.runtimeType) {
                  case Properties:
                    return _buildLamppostInfoCard(context, onSelectedMarkerData, marker.point);
                  case LocationSearchInfo:
                    return _buildLandInfoCard(context, onSelectedMarkerData, marker.point);
                  case IdentifyResultInfo:
                    return _buildAddressInfoCard(context, onSelectedMarkerData, marker.point);
                  default:
                    popupController.hideAllPopups();
                    return Container(); // Handle other types or show a default message
                }
              }),
        ),
      );
    });
  }

  Widget _buildLamppostInfoCard(context, Properties properties, LatLng point) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.black54),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCard('Lamp Post Number', properties.Lamp_Post_Number),
          _buildCard('Latitude', properties.Latitude),
          _buildCard('Longitude', properties.Longitude),
          _buildCard('District', properties.District),
          _buildCard('Location', properties.Location),
          buildGoToMapButton(context, point),
        ],
      )
    );
  }

  Widget _buildLandInfoCard(context, dynamic properties, LatLng point) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.black54),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          buildGoToMapButton(context, point),
        ],
      )
    );
  }

  Widget _buildAddressInfoCard(context, IdentifyResultInfo resultInfo, LatLng point) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.black54),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCard('Information', resultInfo.eheader),
          _buildCard('資訊', resultInfo.cheader),
          const Divider(),
          _buildCard('Address', resultInfo.addressInfo[0].eaddress),
          _buildCard('Address Name', resultInfo.addressInfo[0].ename),
          const Divider(),
          _buildCard('地址', resultInfo.addressInfo[0].caddress),
          _buildCard('地址名稱', resultInfo.addressInfo[0].cname),
          const Divider(),
          _buildCard('座標', '${point.latitude}, ${point.longitude}'),
          buildGoToMapButton(context, point),
        ],
      )
    );
  }

  Widget _buildCard(String title, dynamic value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.toString()),
      ),
    );
  }


}

Widget buildGoToMapButton(context, LatLng latlng) {
  return ElevatedButton.icon(
    onPressed: () => (kIsWeb) ? launchURL('${latlng.latitude}, ${latlng.longitude}') : openMapSheet(context, latlng),
    icon: const Icon(Icons.map),
    label: const Text('Open in Map'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );
}

void launchURL(query, {type = 'google'}){
  switch(type){
    case 'google':
      //https://maps.google.com/maps/search/?api=1&query=22.3193,114.1694
      launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1").replace(
        queryParameters: {
          'api': '1',
          'query': query
        },
      )); //Google Map

      break;
    case 'apple':
     
      break;
    default:
      
  }
}

//Open Map Bottom Sheet
Future<dynamic> openMapSheet(context, LatLng latlng) async {
  try{
    final availableMaps = await MapLauncher.installedMaps;
    return showModalBottomSheet(
      context: context, 
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                for (var map in availableMaps)
                  ListTile(
                    onTap: () {
                      map.showMarker(
                        coords: Coords(latlng.latitude, latlng.longitude),
                        title: map.mapName,
                      );
                      Navigator.of(context).pop();
                    },
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }catch (e){
    
  }
}