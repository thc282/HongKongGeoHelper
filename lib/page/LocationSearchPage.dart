import 'package:flutter/material.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:hong_kong_geo_helper/assets/geolocator.dart';
import 'package:hong_kong_geo_helper/gadget/MarkerControl.dart';
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
  final _searchProvider = LocationSearchProvider();

  @override
  Widget build(BuildContext context){
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
              markerClusterLayer(_popupController, _searchProvider, 
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
    final _searchController = SearchController();

    void _onTyped(String text) {
      // open search view when typing in search bar
      if (!_searchController.isOpen) {
        _searchController.openView();
      }
      // get typeahead recommendations
    }

    void _onSubmitted(String text) async{
      // close search view after pressing enter or selecting a recommendation.
      // (in search bar as well as in search view)
      if (_searchController.isOpen) {
        //_searchController.closeView(text);
      }
      // execute search
      final provider = LocationSearchProvider.of(context);
      final result = await provider.fetchSearchResult(text);
      // update search result
      //provider.updateSearchResult(result);
      final query = _searchController.text;
      _searchController.text = '';
      _searchController.text = query;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: SearchAnchor(
        searchController: _searchController,
        viewOnChanged: _onTyped,
        viewOnSubmitted: _onSubmitted,
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            onChanged: _onTyped,
            onSubmitted: _onSubmitted,
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
                _animatedMapMove(LatLng(latlng.lat, latlng.lng), 17.0);
              },
            );
          }).toList();
          //return List<ListTile>.generate(0, (index) => const ListTile());
        },
      )
    );
  }

  /*=================================
   * Animation Controller
   * =================================
   */
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}