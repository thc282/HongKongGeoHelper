import 'dart:core';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LamppostInfo{
  final String timeStamp;
  final List<Feature> features;
  final int numberReturned;
  final String type;
  final int numberMatched;

  LamppostInfo({
    required this.timeStamp,
    required this.features,
    required this.numberReturned,
    required this.type,
    required this.numberMatched,
  });

  factory LamppostInfo.fromJson(Map<String, dynamic> json){
    return LamppostInfo(
      timeStamp: json['timeStamp'],
      features: [...json['features']].map((feature) => Feature.fromJson(feature)).toList(),
      numberReturned: json['numberReturned'],
      type: json['type'],
      numberMatched: json['numberMatched'],
    );
  }

  @override
  String toString(){
    return 'timeStamp: $timeStamp, features: $features, numberReturned: $numberReturned, type: $type, numberMatched: $numberMatched';
  }
}

class Feature{
  final Geometry geometry;
  final String type;
  final Properties properties;

  Feature({
    required this.geometry,
    required this.type,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json){
    return Feature(
      geometry: Geometry.fromJson(json['geometry']),
      type: json['type'],
      properties: Properties.fromJson(json['properties']),
    );
  }

  @override
  String toString(){
    return 'geometry: $geometry, type: $type, properties: $properties';
  }
}

class Geometry{
  final List<double> coordinates;
  final String type;

  Geometry({
    required this.coordinates,
    required this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json){
    return Geometry(
      coordinates: List<double>.from(json['coordinates']),
      type: json['type'],
    );
  }

  @override
  String toString(){
    return 'coordinates: $coordinates, type: $type';
  }
}

class Properties {
  final Map<String, dynamic> _data;
  
  Properties(this._data);
  
  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(json);
  }
  
  dynamic operator [](String key) => _data[key];
  
  bool hasKey(String key) => _data.containsKey(key);
  
  // 為常用屬性提供getter
  int? get OBJECTID => _data['OBJECTID'];
  String? get Lamp_Post_Number => _data['Lamp_Post_Number'];
  String? get District => _data['District'];
  String? get Location => _data['Location'];
  double? get Latitude => _data['Latitude'];
  double? get Longitude => _data['Longitude'];
  
  @override
  String toString() => _data.toString();
}

/* ==============================================
  * 以下為LocationSearch的API資料模型
  * ==============================================
  */
class LocationSearchInfo {
  final Map<String, dynamic> _data;

  LocationSearchInfo(this._data);

  factory LocationSearchInfo.fromJson(Map<String, dynamic> json) {
    return LocationSearchInfo(json);
  }

  dynamic operator [](String key) => _data[key];

  bool hasKey(String key) => _data.containsKey(key);

  // 為常用屬性提供getter
  String get addressZH => _data['addressZH'];
  String get nameZH => _data['nameZH'];
  String get districtZH => _data['districtZH'];
  double get x => (_data['x'] as num).toDouble();
  double get y => (_data['y'] as num).toDouble();
  String get nameEN => _data['nameEN'];
  String get addressEN => _data['addressEN'];
  String get districtEN => _data['districtEN'];

  @override
  String toString() => _data.toString();
}


/* ==============================================
  * 以下為LocationIdentify的API資料模型
  * ==============================================
  */
class LocationIdentifyInfo {
  final Map<String, dynamic> _data;

  LocationIdentifyInfo(this._data);

  factory LocationIdentifyInfo.fromJson(Map<String, dynamic> json) {
    return LocationIdentifyInfo(json);
  }

  dynamic operator [](String key) => _data[key];

  bool hasKey(String key) => _data.containsKey(key);

  // 為常用屬性提供getter
  List<IdentifyResultInfo> get results => [..._data['results'].map((result) => IdentifyResultInfo.fromJson(result))];

  @override
  String toString() => _data.toString();
}

class IdentifyResultInfo{
  final Map<String, dynamic> _data;

  IdentifyResultInfo(this._data);

  factory IdentifyResultInfo.fromJson(Map<String, dynamic> json){
    return IdentifyResultInfo(json);
  }

  dynamic operator [](String key) => _data[key];

  bool hasKey(String key) => _data.containsKey(key);

  // 為常用屬性提供getter
  List<IdentifyAddressInfo> get addressInfo => [..._data['addressInfo'].map((address) => IdentifyAddressInfo.fromJson(address))];
  String? get eheader => _data['eheader'];
  String? get type => _data['type'];
  String? get cheader => _data['cheader'];

  @override
  String toString() => _data.toString();
}

class IdentifyAddressInfo{
  final Map<String, dynamic> _data;

  IdentifyAddressInfo(this._data);

  factory IdentifyAddressInfo.fromJson(Map<String, dynamic> json){
    return IdentifyAddressInfo(json);
  }

  dynamic operator [](String key) => _data[key];

  bool hasKey(String key) => _data.containsKey(key);

  // 為常用屬性提供getter
  String? get eaddress => _data['eaddress'];
  String? get addressType => _data['addressType'];
  String? get cname => _data['cname'];
  String? get otherCname => _data['otherCname'];
  double? get roofLevel => _data['roofLevel'];
  String? get bdcsuid => _data['bdcsuid'];
  String? get ename => _data['ename'];
  String? get otherEname => _data['otherEname'];
  double get x => (_data['x'] ?? 0 as num).toDouble();
  String? get nameStatus => _data['nameStatus'];
  double get y => (_data['y'] ?? 0 as num).toDouble();
  String? get caddress => _data['caddress'];
  double get baseLevel => _data['baseLevel'];
  List<IdentifyResultInfo?> get facility => [...?_data['facility']?.map((f) => f != null ? IdentifyResultInfo.fromJson(f) : null)];
  String get uniqueId => _data['uniqueId'];
  List<Hashtag> get hashtag => [..._data['hashTag'].map((hashtag) => Hashtag.fromJson(hashtag))];
  String get ltype => _data['LTYPE'];
  String get lotName => _data['LOTNAME'];
  String get lotId => _data['LOTID'];
  String get prn => _data['PRN'];
  String get lotFullName => _data['LOT_FULLNAME'];

  //inner addressInfo (extra)
  int get zoomLevel => _data['zoomLevel'];
  dynamic get distance => _data['distance'];
  dynamic get polyGeometry => _data['polyGeometry'];
  dynamic get eextrainfoArray => _data['eextrainfoArray'];
  dynamic get photos => _data['photos'];
  dynamic get einfo => _data['einfo'];
  Map<String, dynamic> get eextrainfo => _data['eextrainfo'];
  dynamic get group => _data['group'];
  String get faciType => _data['faciType'];
  Map<String, dynamic> get cextrainfo => _data['cextrainfo'];
  dynamic get cextrainfoArray => _data['cextrainfoArray'];
  dynamic get cinfo => _data['cinfo'];

  @override
  String toString() => _data.toString();
}

class Facility{
  final Map<String, dynamic> _data;

  Facility(this._data);

  factory Facility.fromJson(Map<String, dynamic> json){
    return Facility(json);
  }

  dynamic operator [](String key) => _data[key];

  bool hasKey(String key) => _data.containsKey(key);

  // 為常用屬性提供getter
  List<IdentifyAddressInfo> get addressInfo => [..._data['addressInfo'].map((address) => IdentifyAddressInfo.fromJson(address))];

  @override
  String toString() => _data.toString();
}

class Hashtag{
  final Map<String, dynamic> _data;

  Hashtag(this._data);

  factory Hashtag.fromJson(Map<String, dynamic> json){
    return Hashtag(json);
  }

  dynamic operator [](String key) => _data[key];

  bool hasKey(String key) => _data.containsKey(key);

  // 為常用屬性提供getter
  String get edisplay => _data['edisplay'];
  String get cdisplay => _data['cdisplay'];
  String get addressType => _data['addressType'];
  String get tagType => _data['tagType'];
  String get id => _data['id'];

  @override
  String toString() => _data.toString();
}