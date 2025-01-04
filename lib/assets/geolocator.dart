import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 先檢查有無開啟定位功能
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    //錯誤排除
    return Future.error('Location services are disabled.');
  }
  
  // 接著檢查有無開啟定位權限
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 錯誤排除
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Android預設若拒絕兩次則會永久關閉(deniedForever)，使用者需至設定中手動開啟
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.'
    );
  } 

  // 如成功取得權限，使用以下function取得位置
  return await Geolocator.getCurrentPosition();
}

Future<LatLng> latlng(BuildContext context) async {
  try {
    final position = await _determinePosition();
    return LatLng(position.latitude, position.longitude);
  } catch (e) { //如出現錯誤則跳出對話方塊提示使用者
    late LatLng latlng;
    await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              contentPadding: const EdgeInsets.all(8.0),
              children: [
                const Text("請開啟定位功能與權限以定位"),
                TextButton(
                    onPressed: () async {
                      final permission = 
                        await Geolocator.requestPermission();
                      if (permission == LocationPermission.deniedForever) {
                        latlng = const LatLng(22.3193, 114.1694);
                      // 如為deniedForever就直接提供一個預設值
                      } else {
                        final position = await Geolocator.getCurrentPosition();
                        latlng = LatLng(position.latitude, position.longitude);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("確定"))
              ],
            ));
    return latlng;
  }
}