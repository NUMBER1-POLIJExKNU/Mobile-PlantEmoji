import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_data.dart';
import 'diary_entry.dart';

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String plantId = 'plant-01';

  Uri _apiUri(String path, [Map<String, String>? queryParameters]) {
    final base = _configuredBaseUrl.isEmpty
        ? Uri.base
        : Uri.parse(_configuredBaseUrl);
    return base.resolve(path).replace(queryParameters: queryParameters);
  }

  Future<SensorData?> fetchLatestSensorData() async {
    try {
      final response = await http.get(
        _apiUri('/api/sensor-history', {'plantId': plantId}),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return SensorData.fromJson(decoded.last);
        }
        if (decoded is Map<String, dynamic>) {
          if (decoded['latest'] != null) {
            return SensorData.fromJson(decoded['latest']);
          }
          return SensorData.fromJson(decoded);
        }
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
    return null;
  }

  Future<List<DiaryEntry>> fetchDiaryEntries() async {
    try {
      final response = await http.get(
        _apiUri('/api/diary-history', {'plantId': plantId, 'limit': '20'}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((entry) => DiaryEntry.fromJson(entry)).toList();
      }
    } catch (e) {
      print('Error fetching diary: $e');
    }
    return [];
  }

  Future<bool> saveDiaryEntry(DiaryEntry entry) async {
    try {
      final response = await http.post(
        _apiUri('/api/diary-add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'plantId': plantId, 'note': entry.quote}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving diary entry: $e');
    }
    return false;
  }

  Future<CollectionProgress?> fetchCollectionProgress() async {
    try {
      final response = await http.get(
        _apiUri('/api/collection-unlocked', {'plantId': plantId}),
      );
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return CollectionProgress.fromJson(decoded);
        }
      }
    } catch (e) {
      print('Error fetching collection status: $e');
    }
    return null;
  }

  Future<CameraScanResult> scanPlant(String imageBase64) async {
    try {
      final response = await http.post(
        _apiUri('/api/camera-scan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'plantId': plantId,
          'imageBase64': imageBase64,
          'mimeType': 'image/jpeg',
          'locale': 'en',
        }),
      );
      final dynamic decoded = json.decode(response.body);
      if (response.statusCode == 429) {
        return const CameraScanResult(
          ok: false,
          message: 'Please wait a few seconds before scanning again.',
        );
      }
      if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
        if (decoded['disabled'] == true) {
          return const CameraScanResult(
            ok: true,
            message: 'Photo captured. AI advice is unavailable right now.',
          );
        }
        final advisory = decoded['advisory'];
        return CameraScanResult(
          ok: true,
          message: advisory is String && advisory.isNotEmpty
              ? advisory
              : 'No visible pest problem was found.',
        );
      }
      return CameraScanResult(
        ok: false,
        message: decoded is Map<String, dynamic>
            ? 'Scan failed: ${decoded['error'] ?? 'unknown error'}'
            : 'Scan failed. Please try again.',
      );
    } catch (e) {
      print('Error scanning plant: $e');
      return const CameraScanResult(
        ok: false,
        message: 'Could not reach the scan service.',
      );
    }
  }
}

class CollectionProgress {
  final List<String> unlockedIds;
  final int level;
  final int totalXp;
  final int currentStreak;

  const CollectionProgress({
    required this.unlockedIds,
    required this.level,
    required this.totalXp,
    required this.currentStreak,
  });

  factory CollectionProgress.fromJson(Map<String, dynamic> json) {
    final ids = json['unlockedIds'];
    return CollectionProgress(
      unlockedIds: ids is List ? ids.map((id) => id.toString()).toList() : [],
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    );
  }
}

class CameraScanResult {
  final bool ok;
  final String message;

  const CameraScanResult({required this.ok, required this.message});
}
