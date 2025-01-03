import 'dart:core';

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
      //features: (json['features'] as List).map((feature) => Feature.fromJson(feature)).toList(),
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
  final DynamicProperties properties;

  Feature({
    required this.geometry,
    required this.type,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json){
    return Feature(
      geometry: Geometry.fromJson(json['geometry']),
      type: json['type'],
      properties: DynamicProperties.fromJson(json['properties']),
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

class Properties{
  final int OBJECTID;
  final dynamic Lamp_Post_Number;
  final double Latitude;
  final String District;
  final double Longitude;
  final String Location;

  Properties({
    required this.OBJECTID,
    required this.Lamp_Post_Number,
    required this.Latitude,
    required this.District,
    required this.Longitude,
    required this.Location,
  });

  factory Properties.fromJson(Map<String, dynamic> json){
    return Properties(
      OBJECTID: json['OBJECTID'],
      Lamp_Post_Number: json['Lamp_Post_Number'],
      Latitude: json['Latitude'],
      District: json['District'],
      Longitude: json['Longitude'],
      Location: json['Location'],
    );
  }

  @override
  String toString(){
    return 'OBJECTID: $OBJECTID, Lamp_Post_Number: $Lamp_Post_Number, Latitude: $Latitude, District: $District, Longitude: $Longitude, Location: $Location';
  }
}

class DynamicProperties {
  final Map<String, dynamic> _data;
  
  DynamicProperties(this._data);
  
  factory DynamicProperties.fromJson(Map<String, dynamic> json) {
    return DynamicProperties(json);
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