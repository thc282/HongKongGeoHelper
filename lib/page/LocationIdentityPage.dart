import 'package:flutter/material.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:hong_kong_geo_helper/gadget/MarkerControl.dart';
import 'package:hong_kong_geo_helper/mics/LocationIdentifyProvider.dart';
import 'package:hong_kong_geo_helper/mics/tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationIdentityTab extends StatefulWidget {
  const LocationIdentityTab({super.key});

  @override
  State<LocationIdentityTab> createState() => _LocationIdentityTabState();
}

class _LocationIdentityTabState extends State<LocationIdentityTab> {
  final mapController = MapController();
  final _popupController = PopupController();
  bool _showResultPanel = false;

  @override
  Widget build(BuildContext context) {
    final locationIdentifyProvider = LocationIdentifyProvider.of(context);
    //LocationIdentifyProvider.testFetch();
    return Stack(
      children: [
        PopupScope(
          popupController: _popupController,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: (_, __) => _popupController.hideAllPopups(),
              onLongPress: (_, latlng) => getLocationIdentity(latlng),
              initialCenter: const LatLng(22.3193, 114.1694),
            ),
            children: [
              openStreetMapTileLayer,
              openStreetMapLabelTileLayer,
              markerClusterLayer(_popupController, locationIdentifyProvider,
                  (provider) {
                //do the data conversion here
                var markerList = <MarkerWithData>[];

                if (provider.identifyResult.results.isNotEmpty) {
                  provider.identifyResult.results
                      .where((e) => e.addressInfo[0].x > 0.0)
                      .forEach((result) {
                    final addressInfo = result.addressInfo[0];
                    //outer addressInfo
                    var latlng = Converter.convert.gridToLatLng(
                        Coordinate(x: addressInfo.x, y: addressInfo.y));
                    markerList.add(MarkerWithData(
                        Marker(
                            point: LatLng(latlng.lat, latlng.lng),
                            child: const Icon(Icons.location_on,
                                size: 20, color: Colors.red)),
                        result));

                    //inner addressInfo
                    addressInfo.facility.forEach((f) {
                      f?.addressInfo.forEach((innerAddress) {
                        var latlng = Converter.convert.gridToLatLng(
                            Coordinate(x: innerAddress.x, y: innerAddress.y));
                        markerList.add(MarkerWithData(
                            Marker(
                                point: LatLng(latlng.lat, latlng.lng),
                                child: const Icon(Icons.location_on,
                                    size: 20, color: Colors.red)),
                            f));
                      });
                    });
                  });
                }
                return markerList;
              }),
            ],
          ),
        ),
        if (_showResultPanel)
          ResultPanel(
            onClose: () => setState(() => _showResultPanel = false),
          ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(
              _showResultPanel ? Icons.close : Icons.info_outline,
              color: Colors.blue,
            ),
            onPressed: () => setState(() => _showResultPanel = !_showResultPanel),
            tooltip: '顯示/隱藏詳細信息',
          )
        ),
      ],
    );
  }

  void getLocationIdentity(LatLng latlng) async {
    final provider = LocationIdentifyProvider.of(context);
    await provider.fetchIdentifyResult(latlng.latitude, latlng.longitude);
    setState(() => _showResultPanel = true);
  }
}

class ResultPanel extends StatefulWidget {
  //final List<IdentifyResultInfo> results;
  final VoidCallback onClose;

  const ResultPanel({required this.onClose, super.key});

  @override
  State<ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<ResultPanel> {
  IdentifyAddressInfo? _selectedFacility;
  final _pageController = PageController(viewportFraction: 1);
  bool _isDetailPage = false;
  final Map<int, bool> _expansionState = {};

  void _selectFacility(facility) {
    setState(() {
      _selectedFacility = facility;
      _isDetailPage = true;
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  void _goBack() {
    setState(() {
      _isDetailPage = false;
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationIdentifyProvider = LocationIdentifyProvider.of(context);
    final results = locationIdentifyProvider.identifyResult.results;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: 10,
      top: 10,
      width: 300,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // 禁止手勢滑動
          children: [
            _buildResultList(results),
            _buildDetailWithBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultList(List<IdentifyResultInfo> results) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(_isDetailPage ? -300 : 0, 0, 0),
      curve: Curves.easeInOut,
      child: (results.isEmpty) 
        ? const Center(child: Text('未有任何結果'))
        : Column(
          children: [
            ListTile(
              title: Text( results[0].addressInfo[0].cname ?? '未知建築物'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(results[0].addressInfo[0].caddress ?? '未知地址'),
                  Text(results[0].addressInfo[0].eaddress ?? 'Unknown Address'),
                ],
              ),
            ),
            (results[0].addressInfo[0].facility.isEmpty)
            ? const Center(child: Text('沒有找到相關設施'))
            : Expanded(
              child: ListView.builder(
                itemCount: results[0].addressInfo[0].facility.length,
                itemBuilder: (context, index) {
                  final facility =
                      results[0].addressInfo[0].facility[index];
                  final expansionKey = index;

                  if (facility == null) return const Center(child: Text('沒有找到相關設施'));
                  final facAddressInfo = facility.addressInfo;
                  return ExpansionTile(
                    key: Key('expansion_$expansionKey'),
                    initiallyExpanded:
                        _expansionState[expansionKey] ?? false,
                    onExpansionChanged: (expanded) {
                      setState(
                          () => _expansionState[expansionKey] = expanded);
                    },
                    title: Text(facility.cheader ?? '未知地址'),
                    subtitle:
                        Text(facility.eheader ?? 'Unknown Facility'),
                    children: [
                      if (facAddressInfo.isNotEmpty)
                        ...facAddressInfo.map((facAddrInfo) {
                          return ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: Text(facAddrInfo.cname ?? '未知設施'),
                            onTap: () => _selectFacility(facAddrInfo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(facAddrInfo.caddress ?? '未知地址'),
                                Text(facAddrInfo.eaddress ?? 'Unknown Address'),
                              ],
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            )
          ],
        )
    );
  }

  Widget _buildDetailWithBackButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(_isDetailPage ? 0 : 300, 0, 0),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          // 返回按钮
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBack,
                ),
                const Text('詳細信息', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          // 详情内容
          Expanded(child: _buildDetailPanel()),
        ],
      ),
    );
  }

  Widget _buildDetailPanel() {
    if (_selectedFacility == null) {
      return const SizedBox.shrink();
    }

    final facility = _selectedFacility!;
    final extraInfo = facility.cextrainfo;
    final latlng = Converter.convert.gridToLatLng(Coordinate(x: facility.x, y: facility.y));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('名稱: ${facility.cname}'),
                Text('地址: ${facility.caddress}'),
                Text('座標: ${facility.x}, ${facility.y}'),
                const Divider(),
                ...extraInfo.entries.map((entry) {
                  String value = entry.value.replaceAll(RegExp(r'<[^>]*>'), '');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('${entry.key}: $value'),
                  );
                }),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: buildGoToMapButton(context, LatLng(latlng.lat, latlng.lng)),
        )
      ],
    );
  }
}
