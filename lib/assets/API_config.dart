import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:http/http.dart' as http;

enum ApiEndpoint {
  lamppost(
    path: '',
    defaultParams: {
      'id': 'hyd_rcd_1629267205229_84645',
      'layer': 'lamppost',
      'limit': '1',
      'offset': '0',
    }
  ),
  traffic(
    path: 'traffic',
    defaultParams: {
      'layer': 'traffic'
    }
  );

  const ApiEndpoint({
    required this.path,
    this.defaultParams = const {},
  });

  final String path;
  final Map<String, String> defaultParams;
}

class ApiService {
  static const String baseUrl = 'https://api.csdi.gov.hk/apim/dataquery/api/';
  
  static Future<(int, String)> fetchData({
    required ApiEndpoint endpoint,
    String method = 'GET',
    Map<String, String> params = const {},
    String? body,
  }) async {
    try {
      final queryParams = Map<String, String>.from(endpoint.defaultParams)
        ..addAll(params);
      
      final uri = Uri.parse('$baseUrl${endpoint.path}')
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