import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_data.dart';

class ApiService {
  // TODO: Replace with the actual Vercel URL
  static const String baseUrl = 'https://main-plant-moji.vercel.app';

  Future<SensorData?> fetchLatestSensorData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sensor-history'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Assuming the last item is the latest
          return SensorData.fromJson(data.last);
        }
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
    return null;
  }
}
