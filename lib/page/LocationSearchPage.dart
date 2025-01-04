import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hong_kong_geo_helper/assets/geolocator.dart';
import 'package:hong_kong_geo_helper/gadget/buildmarker.dart';
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

class _LocationSearchTabState extends State<LocationSearchTab>{

  late Iterable<Widget> _lastOptions = <Widget>[];

  @override
  Widget build(BuildContext context){
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(22.3193, 114.1694),
          ),
          children: [
            openStreetMapTileLayer,
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
      await LocationSearchProvider.of(context).fetchSearchResult(text);
      // update search result
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
            onTap: () => controller.openView,
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
              onTap: () {
                controller.closeView(result.nameZH);
                // 處理選擇邏輯，例如更新地圖位置
                // 可以使用 result.x 和 result.y 來定位
              },
            );
          }).toList();
          //return List<ListTile>.generate(0, (index) => const ListTile());
        },
      )
    );
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