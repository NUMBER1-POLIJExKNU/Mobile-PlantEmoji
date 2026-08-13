import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_data.dart';
import 'diary_entry.dart';

class ApiService {
  static const String baseUrl = 'https://main-plant-moji.vercel.app';

  Future<SensorData?> fetchLatestSensorData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sensor-history'));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        
        if (decoded is List) {
          if (decoded.isNotEmpty) {
            return SensorData.fromJson(decoded.last);
          }
        } else if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('latestReading') && decoded['latestReading'] != null) {
            return SensorData.fromJson(decoded['latestReading']);
          } else {
            return SensorData.fromJson(decoded);
          }
        }
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
    return null;
  }

  // --- Diary API ---
  
  Future<List<DiaryEntry>> fetchDiaryEntries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/diary-history'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => DiaryEntry.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching diary: $e');
    }
    return [];
  }

  Future<bool> saveDiaryEntry(DiaryEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/diary-add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(entry.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving diary entry: $e');
    }
    return false;
  }

  // --- Collection API ---

  Future<List<String>> fetchUnlockedCollectionIds() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/collection-unlocked'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('Error fetching collection status: $e');
    }
    return [];
  }
}
