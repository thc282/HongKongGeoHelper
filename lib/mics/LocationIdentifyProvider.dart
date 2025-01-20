import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/API_config.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hkgrid80_wgs84_converter/flutter_hkgrid80_wgs84_converter.dart';


class Locationidentifyprovider extends ChangeNotifier{
  late LocationIdentifyInfo _identifyResult;
  String? _errorMessage;

  LocationIdentifyInfo get identifyResult => _identifyResult;
  String? get errorMessage => _errorMessage;

  static Future<void> testFetch() async {
    final provider = Locationidentifyprovider();
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
      } else {
        _errorMessage = '查詢失敗: $statusCode';
      }
    }catch(e){
      _identifyResult = LocationIdentifyInfo(Map());
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
}