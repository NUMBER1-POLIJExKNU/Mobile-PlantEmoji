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
      temperature: (json['temperature'] ?? json['temp'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0).toInt(),
      light: (json['light'] ?? 0).toInt(),
      soilPH: (json['soilPH'] ?? json['soil_ph'] ?? 0.0).toDouble(),
    );
  }
}
