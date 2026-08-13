import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sensor_data.dart';
import 'diary_entry.dart';

class ApiService {
  static const String baseUrl = 'https://main-plant-moji-henna.vercel.app';

  // Supabase Config - REPLACE WITH YOUR ACTUAL VALUES
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseKey = 'YOUR_ANON_KEY';

  final _supabase = Supabase.instance.client;

  Future<SensorData?> fetchLatestSensorData() async {
    try {
      // Direct Supabase Query
      final data = await _supabase
          .from('sensor_readings')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (data != null) {
        return SensorData.fromJson(data);
      }
    } catch (e) {
      print('Error fetching from Supabase: $e');

      // Fallback to Vercel API if Supabase fails or is not configured
      return _fetchFromVercel();
    }
    return null;
  }

  Future<SensorData?> _fetchFromVercel() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sensor-history'));
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return SensorData.fromJson(decoded.last);
        }
      }
    } catch (e) {
      print('Vercel Fallback Error: $e');
    }
    return null;
  }

  // --- Diary API ---
  
  Future<List<DiaryEntry>> fetchDiaryEntries() async {
    try {
      final data = await _supabase
          .from('growth_records')
          .select()
          .order('created_at', ascending: false);

      return (data as List).map((e) => DiaryEntry.fromJson(e)).toList();
    } catch (e) {
      print('Supabase Diary Error: $e');
      return [];
    }
  }

  Future<bool> saveDiaryEntry(DiaryEntry entry) async {
    try {
      await _supabase.from('growth_records').insert(entry.toJson());
      return true;
    } catch (e) {
      print('Supabase Save Error: $e');
      return false;
    }
  }

  // --- Collection API ---

  Future<List<String>> fetchUnlockedCollectionIds() async {
    try {
      final data = await _supabase
          .from('unlocked_collection')
          .select('item_id');

      return (data as List).map((e) => e['item_id'].toString()).toList();
    } catch (e) {
      print('Supabase Collection Error: $e');
      return [];
    }
  }
}
