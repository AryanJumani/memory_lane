/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationService {
  final _apiKey = dotenv.env['GOOGLE_API_KEY'];

  Future<String> getNearestLandmark(double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          return 'No landmarks found';
        }
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
*/
