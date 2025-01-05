import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

  @override
  Widget build(BuildContext context){
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: LatLng(22.3193, 114.1694),
          ),
          children: [
            openStreetMapTileLayer,
            LocationMarkerLayer(
              Icons.location_on,
              (feature) {   //when point is tapped

              }
            )
          ],
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
      provider.updateSearchResult(result);
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
                var (lat, lon) = HK80Converter.gridToLatLon(result.y, result.x);
                _animatedMapMove(LatLng(lat, lon), 17.0);
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

/*class MapTab extends StatelessWidget {
  const MapTab( {super.key} );

  @override
  Widget build(BuildContext context){
    return _buildMapTab(context);
  }

  Widget _buildMapTab(context){
    return Stack(
        children: [
          FutureBuilder<LatLng>(
            future: latlng(context),
            builder: (context, snapshot){
              final mapController = MapController();
              
              if(snapshot.hasData){
                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: snapshot.data!, 
                    initialZoom: 15.0,
                    onTap: (_, p) {
                      //print(p);
                    }
                  ),
                  children: [
                    openStreetMapTileLayer,
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: snapshot.data!,
                          child: const Icon(Icons.location_on, size: 20, color: Colors.red),
                        )
                      ],
                    )
                  ],
                );
              }
              return const Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8.0),
                    Text("初始化中，請稍候")
                  ],
                ),
              );
            }
          )
        ],
      );
  }
}*/