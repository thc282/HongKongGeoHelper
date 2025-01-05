import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:hong_kong_geo_helper/mics/LocationSearchProvider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

//Lamppost Search Page
class MapPinLayer extends StatelessWidget {
  final List<Feature> features;
  final IconData icon;
  final Function(Feature) onTapCallback;

  const MapPinLayer(
    this.features,
    this.icon,
    this.onTapCallback,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [...features.map((feature){
        final coor = feature.geometry.coordinates;
        return Marker(
          point: LatLng(coor[1], coor[0]),
          child: GestureDetector(
            onTap: () => onTapCallback(feature), //_openLamppostMarker(context, coor, feature.properties),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
        );
      })]
    );
  }
}

//Location Search Page
class LocationMarkerLayer extends StatelessWidget{
  final IconData icon;
  final Function(LocationSearchInfo) onTapCallback;

  const LocationMarkerLayer(
    //this.features,
    this.icon,
    this.onTapCallback,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationSearchProvider>(
      builder: (context, provider, child){
        if(provider.isLoading) return const MarkerLayer(markers: []);
        return MarkerLayer(
          markers: [...provider.searchResult.map((feature){
            //x(easting), y(northing)
            var (lat, lon) = HK80Converter.gridToLatLon(feature.y, feature.x);
            return Marker(
              point: LatLng(lat, lon),
              child: GestureDetector(
                onTap: () => onTapCallback(feature), //_openLamppostMarker(context, coor, feature.properties),
                child: Icon(icon, size: 20, color: Colors.black),
              ),
            );
          })]
        );
      }
    );
  }
}

class HK80Converter {
  static const double pi = 3.141592653589793;
  
  // HK80 參數
  static const double _a = 6378388.0; 
  static const double _e2 = 6.722670022e-3;
  static const double _m0 = 1.0;
  static const double _M0 = 2468395.728;
  static const double _N0 = 819069.80;
  static const double _E0 = 836694.05;
  static const double _vs = 6381480.502;
  static const double _ps = 6344727.809;
  static const double _psi_s = 1.005792635;
  static const double _lambda0 = 114 + 10/60.0 + 42.80/3600.0; // 114°10'42.80"E
  static const double _phi0 = 22 + 18/60.0 + 43.68/3600.0;     // 22°18'43.68"N
  
  // 將網格坐標轉換為經緯度
  static (double, double) gridToLatLon(double N, double E) {
    // 計算 ΔN 和 ΔE
    double deltaN = N - _N0;
    double deltaE = E - _E0;
    
    // 計算 Φp (第一次近似值)
    double M = (deltaN + _M0) / _m0;
    double phi_p = M / (_vs * _m0);
    
    // 透過迭代求得更精確的 Φp
    for(int i = 0; i < 5; i++) {
      double A0 = 1 - _e2/4 - 3*_e2*_e2/64 - 5*_e2*_e2*_e2/256;
      double A2 = 3/8.0 * (_e2 + _e2*_e2/4);
      double A4 = 15/256.0 * _e2*_e2;
      
      double M_calc = _a * (A0*phi_p - A2*sin(2*phi_p) + A4*sin(4*phi_p));
      phi_p = phi_p + (M - M_calc)/(_vs * _m0);
    }
    
    // 計算輔助參數
    double tp = tan(phi_p);
    double pp = _ps;
    double vp = _vs;
    double psip = _psi_s;
    
    // 根據公式 Eq.4 和 Eq.5 計算 λ 和 Φ
    double lambda = _lambda0 * pi/180 + 
                   (deltaE/(_m0*vp))/cos(phi_p) - 
                   (deltaE*deltaE*deltaE/(6*_m0*_m0*_m0*vp*vp*vp))*(psip + 2*tp*tp)/cos(phi_p);
    
    double phi = phi_p - 
                (tp/(_m0*pp)) * (deltaE*deltaE/(2*_m0*vp));
    
    // 轉換為度數
    double lat = phi * 180/pi;
    double lon = lambda * 180/pi;
    
    return (lat, lon);
  }

  static (double, double) latLonToGrid(double lat, double lon) {
    // 轉換為弧度
    double phi = lat * pi/180;
    double lambda = lon * pi/180;
    
    // 計算相對於中央子午線的經度差
    double delta_lambda = lambda - _lambda0 * pi/180;
    
    // 計算 M
    double A0 = 1 - _e2/4 - 3*_e2*_e2/64 - 5*_e2*_e2*_e2/256;
    double A2 = 3/8.0 * (_e2 + _e2*_e2/4);
    double A4 = 15/256.0 * _e2*_e2;
    
    double M = _a * (A0*phi - A2*sin(2*phi) + A4*sin(4*phi));
    
    // 根據公式 Eq.1 和 Eq.2 計算網格坐標
    double N = _N0 + _m0 * ((M - _M0) + _vs * sin(phi) * (delta_lambda*delta_lambda/2) * cos(phi));
    
    double E = _E0 + _m0 * (_vs * delta_lambda * cos(phi) + 
               _vs * (delta_lambda*delta_lambda*delta_lambda/6) * (cos(phi)*cos(phi)*cos(phi)) * 
               (_psi_s - tan(phi)*tan(phi)));
    
    return (N, E);
  }
}