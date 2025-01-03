import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:http/http.dart' as http;

enum ApiEndpoint {
  lamppost(
    baseUrl:  'https://api.csdi.gov.hk/apim/dataquery/api/',
    path: '',
    defaultParams: {
      'id': 'hyd_rcd_1629267205229_84645',
      'layer': 'lamppost',
      'limit': '1',
      'offset': '0',
    }
  ),
  webService(
    baseUrl:  'https://portal.csdi.gov.hk/server/services/common/landsd_rcd_1648571595120_89752/MapServer/',
    path: 'WFSServer',
    defaultParams: {
      'service': 'WFS',
      'version': '2.0.0',
      'request': 'GetFeature',
      'typeNames': 'GEO_PLACE_NAME',
      'outputFormat': 'GeoJSON',
      'srsName': 'EPSG:4326',
      'count': '100',
    }
  );

  const ApiEndpoint({
    required this.baseUrl,
    required this.path,
    this.defaultParams = const {},
  });

  final String baseUrl;
  final String path;
  final Map<String, String> defaultParams;
}

class ApiService {
  static Future<(int, String)> fetchData({
    required ApiEndpoint endpoint,
    String method = 'GET',
    Map<String, String> params = const {},
    String? body,
  }) async {
    try {
      final queryParams = Map<String, String>.from(endpoint.defaultParams)
        ..addAll(params);
      
      final uri = Uri.parse('${endpoint.baseUrl}${endpoint.path}')
          .replace(queryParameters: queryParams);

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
            response = await http.get(uri);
        case 'POST':
          response = await http.post(uri, body: body);
        case 'DELETE':
          response = await http.delete(uri);
        default:
          throw Exception('Unsupported method: $method');
      }

      return (response.statusCode, response.body);
    } catch (e) {
      return (-1, e.toString());
    }
  }
}