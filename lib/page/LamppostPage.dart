import 'package:flutter/material.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:hong_kong_geo_helper/gadget/MarkerControl.dart';
import 'package:hong_kong_geo_helper/gadget/mapMoveAnimation.dart';
import 'package:hong_kong_geo_helper/mics/tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:hong_kong_geo_helper/assets/page_config.dart';
import 'package:hong_kong_geo_helper/assets/API_config.dart';
import 'package:hong_kong_geo_helper/mics/LampSearchProvider.dart';


// LamppostPage Container
/*class LamppostPage extends StatefulWidget {
  const LamppostPage({super.key});

  @override
  State<LamppostPage> createState() => _LamppostPageState();
}

class _LamppostPageState extends State<LamppostPage> {
  dynamic searchResult;

  void _handleSearchResult(dynamic result) {
    setState(() {
      searchResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    /*return TabBarView(
      children: [
        SearchTab(onSearchResult: _handleSearchResult),
        ResultTab(searchResult: searchResult),
      ],
    );*/
  }
}*/

// SearchTab
class LampSearchTab extends StatefulWidget {
  const LampSearchTab({
    super.key,
  });

  @override
  State<LampSearchTab> createState() => _LampSearchTabState();
}

class _LampSearchTabState extends State<LampSearchTab> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final mapController = MapController();
  final _popupController = PopupController();

  @override
  Widget build(BuildContext context) {
    final lampProvider = LampSearchProvider.of(context);
    return Stack(
      children: [
        PopupScope(
          popupController: _popupController,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: (_,__) => _popupController.hideAllPopups(),
              onLongPress: (_, latlng) => openMapSheet(context, latlng),
              initialCenter: const LatLng(22.3193, 114.1694),
            ),
            children: [
              openStreetMapTileLayer,
              openStreetMapLabelTileLayer,
              markerClusterLayer(_popupController, lampProvider, 
              (provider) => 
                provider.searchResult
                .where((result) => result.features.isNotEmpty)
                .map((result) {
                  final latlng = result.features[0].geometry.coordinates;
                  return MarkerWithData(
                    Marker(
                      point: LatLng(latlng[1], latlng[0]),
                      child: const Icon(CustomIcon.lamp_street, size: 20, color: Colors.black)
                    ),
                    result.features[0].properties
                  );
                }).toList()
              ),
            ],
          ),
        ),
        _buildSearchBar()
      ],
    );
  }

  //Search bar function
  void _onSubmitted(String text) async{
    final lampProvider = LampSearchProvider.of(context);
    final result = await lampProvider.fetchSearchResult(text);
    
    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PageConfigEnum.lamppost.descriptions['noresult']!),
        ),
      );
    } else if(result[0].features.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PageConfigEnum.lamppost.descriptions['nolamppost']!),
        ),
      );
    } else{
      final latlng = result[0].features[0].geometry.coordinates;
      AnimationMove.animatedMapMove(LatLng(latlng[1], latlng[0]), 17, mapController, this);
    }
  }

  Widget _buildSearchBar(){
    return Container(
      padding: const EdgeInsets.all(16),
      child: SearchBar(
        controller: _textController,
        onSubmitted: _onSubmitted,
        padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16)),
        leading: const Icon(Icons.search),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}