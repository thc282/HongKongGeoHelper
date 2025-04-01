import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/API_config.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';


class LocationIdentifyProvider extends ChangeNotifier{
  LocationIdentifyInfo _identifyResult = LocationIdentifyInfo({"results": []});
  bool _showResultPanel = false;
  String? _errorMessage;

  LocationIdentifyInfo get identifyResult => _identifyResult;
  bool get showResultPanel => _showResultPanel;
  String? get errorMessage => _errorMessage;

  void setShowResultPanel(bool show){
    _showResultPanel = show;
    notifyListeners();
  }

  static Future<void> testFetch() async {
    final provider = LocationIdentifyProvider();
    final latlng = Converter.convert.gridToLatLng(Coordinate(x: 835665, y: 817198));
    final result = await provider.fetchIdentifyResult(latlng.lat, latlng.lng);
    print('Identify Result: ${result.toString()}');
    if (provider.errorMessage != null) {
      print('Error: ${provider.errorMessage}');
    }
  }

  Future<LocationIdentifyInfo> fetchIdentifyResult(double lat, double lng) async{
    try{
      var gridCoor = Converter.convert.latLngToGrid(Coordinate(lat: lat, lng: lng));
      var url = "https://geodata.gov.hk/gs/api/v1.0.0/identify?x=${gridCoor.x}&y=${gridCoor.y}&lang=zh";
      print(url);
      var test = 1;
      switch(test){
        case 1:
          break;
        case 2:
          gridCoor.x = 842023.9378963539;
          gridCoor.y = 831243.0203910804;
          break;
        case 3:
          gridCoor.x = 842051.0;
          gridCoor.y = 831347.0;
          break;
        case 4:
          gridCoor.x = 839455.0;
          gridCoor.y = 829241.0;
          break;
        case 5:
          gridCoor.x = 836883.0;
          gridCoor.y = 826027.0;
          break;
        case 6:
          gridCoor.x = 841822.8378107442;
          gridCoor.y = 831618.9243198215;
          break;
      }
      final (statusCode, responseBody) = 
      await ApiService.fetchData(
        endpoint: ApiEndpoint.locationIdentify,
        params: {
          'x': gridCoor.x.toString(),
          'y': gridCoor.y.toString(),
        },
      );
      if (statusCode == 200) {
        _identifyResult = parseIdentifyResults(responseBody);
        setShowResultPanel(true);
        notifyListeners();
      } else {
        _errorMessage = '查詢失敗: $statusCode';
      }
    }catch(e){
      _identifyResult = LocationIdentifyInfo(Map());
      setShowResultPanel(false);
    }
    return _identifyResult;
  }

  LocationIdentifyInfo parseIdentifyResults(String responseBody){
    try{
      final Map<String, dynamic> identifyInfo = json.decode(responseBody);
      
      return LocationIdentifyInfo(identifyInfo);
    }catch(e){
      _errorMessage = '數據解析錯誤: ${e.toString()}';
      return LocationIdentifyInfo({'results': []});
    }
  }

  static LocationIdentifyProvider of(BuildContext context){
    return Provider.of<LocationIdentifyProvider>(context, listen: false);
  }
}