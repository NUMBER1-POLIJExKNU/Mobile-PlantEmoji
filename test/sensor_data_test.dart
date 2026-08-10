import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_smartfarm/sensor_data.dart';

void main() {
  test('SensorData.fromJson parses correctly', () {
    final json = {
      'temperature': 25.5,
      'humidity': 60,
      'light': 500,
      'soilPH': 6.5
    };

    final data = SensorData.fromJson(json);

    expect(data.temperature, 25.5);
    expect(data.humidity, 60);
    expect(data.light, 500);
    expect(data.soilPH, 6.5);
  });

  test('SensorData.fromJson handles missing fields', () {
    final json = <String, dynamic>{};

    final data = SensorData.fromJson(json);

    expect(data.temperature, 0.0);
    expect(data.humidity, 0);
    expect(data.light, 0);
    expect(data.soilPH, 0.0);
  });
}
