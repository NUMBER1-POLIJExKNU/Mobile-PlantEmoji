class SensorData {
  final double temperature;
  final int humidity;
  final int light;
  final double soilPH;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.soilPH,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: json['humidity'] ?? 0,
      light: json['light'] ?? 0,
      soilPH: (json['soilPH'] ?? 0.0).toDouble(),
    );
  }
}
