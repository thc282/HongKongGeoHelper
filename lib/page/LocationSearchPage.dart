import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:hong_kong_geo_helper/assets/geolocator.dart';
import 'package:hong_kong_geo_helper/gadget/MarkerControl.dart';
import 'package:hong_kong_geo_helper/gadget/mapMoveAnimation.dart';
import 'package:hong_kong_geo_helper/mics/LocationSearchProvider.dart';
import 'package:hong_kong_geo_helper/mics/tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../assets/page_config.dart';

class LocationSearchTab extends StatefulWidget {
  const LocationSearchTab({super.key});

  @override
  State<LocationSearchTab> createState() => _LocationSearchTabState();
}

class _LocationSearchTabState extends State<LocationSearchTab> with TickerProviderStateMixin {
  final mapController = MapController();
  final _popupController = PopupController();

  @override
  Widget build(BuildContext context){
    final searchProvider = LocationSearchProvider.of(context);
    return Stack(
      children: [
        PopupScope(
          popupController: _popupController,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: (_,__) => _popupController.hideAllPopups(),
              onLongPress: (_, latlng) => (kIsWeb) ? launchURL('${latlng.latitude}, ${latlng.longitude}') : openMapSheet(context, latlng),
              initialCenter: const LatLng(22.3193, 114.1694),
            ),
            children: [
              openStreetMapTileLayer,
              openStreetMapLabelTileLayer,
              markerClusterLayer(_popupController, searchProvider, 
              (provider) => 
                provider.searchResult.map((result) {
                  var latlng = Converter.convert.gridToLatLng(Coordinate(x:result.x, y:result.y));
                  return MarkerWithData(
                    Marker(
                      point: LatLng(latlng.lat, latlng.lng),
                      child: const Icon(Icons.location_on, size: 20, color: Colors.red)
                    ),
                    result
                  );
                }).toList()
              ),
            ],
          ),
        ),
        _buildSearchBar(context)
      ],
    );
  }

  Widget _buildSearchBar(context){
    final searchController = SearchController();

    void onTyped(String text) {
      // open search view when typing in search bar
      if (!searchController.isOpen) {
        searchController.openView();
      }
      // get typeahead recommendations
    }

    void onSubmitted(String text) async{
      // close search view after pressing enter or selecting a recommendation.
      // (in search bar as well as in search view)
      if (searchController.isOpen) {
        //_searchController.closeView(text);
      }
      // execute search
      final provider = LocationSearchProvider.of(context);
      /*final result =*/ await provider.fetchSearchResult(text);
      // update search result
      //provider.updateSearchResult(result);
      final query = searchController.text;
      searchController.text = '';
      searchController.text = query;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: SearchAnchor(
        searchController: searchController,
        viewOnChanged: onTyped,
        viewOnSubmitted: onSubmitted,
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            onChanged: onTyped,
            onSubmitted: onSubmitted,
            padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16)),
            leading: const Icon(Icons.search),
            onTap: () => controller.openView(),
          );
        }, suggestionsBuilder: (context, controller) {
          final provider = LocationSearchProvider.of(context);
  
          if (provider.isLoading) {
            return [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            ];
          }

          if (provider.errorMessage != null) {
            return [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(provider.errorMessage!),
                ),
              )
            ];
          }

          if (provider.searchResult.isEmpty) {
            return [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('沒有找到相關結果'),
                ),
              )
            ];
          }

          return provider.searchResult.map((result) {
            return ListTile(
              title: Text(result.nameZH),
              subtitle: Text(result.addressZH),
              trailing: Text(result.districtZH),
              onTap: () {   //when a suggestion is tapped
                controller.closeView(result.nameZH);
                // goto location
                var latlng = Converter.convert.gridToLatLng(Coordinate(x:result.x, y:result.y));
                AnimationMove.animatedMapMove(LatLng(latlng.lat, latlng.lng), 17.0, mapController, this);
              },
            );
          }).toList();
          //return List<ListTile>.generate(0, (index) => const ListTile());
        },
      )
    );
  }
}