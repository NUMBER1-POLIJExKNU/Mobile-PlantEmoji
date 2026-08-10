# Integration with Main-PlantMoji Backend

This plan outlines the steps to connect the **Mobile Plant Emoji** Flutter app to the **Main-PlantMoji** backend hosted on Vercel. This will allow the app to fetch and display real-time sensor data (Temperature, Humidity, Light, Soil pH) sent from an Arduino via Node-RED.

## User Review Required

- **Vercel API URL**: I have used `https://main-plant-moji.vercel.app` as a placeholder. Please provide the actual deployment URL if different.
- **API Endpoint**: I am assuming `GET /api/sensor-history` returns a list of sensor readings, with the latest reading at the end of the list.
- **Polling Interval**: I plan to implement simple polling (e.g., every 10 seconds) to update the UI. Should we consider Supabase Realtime instead for a more efficient update?

## Proposed Changes

### Core Integration

#### [NEW] [sensor_data.dart](file:///C:/Users/ramar/StudioProjects/Mobile-PlantEmoji/lib/sensor_data.dart)
- Define a `SensorData` model to parse JSON responses from the Vercel API.
- Fields: `temperature`, `humidity`, `light`, `soilPH`.

#### [NEW] [api_service.dart](file:///C:/Users/ramar/StudioProjects/Mobile-PlantEmoji/lib/api_service.dart)
- Implement `ApiService` to handle HTTP GET requests to the Vercel backend.
- Method `fetchLatestSensorData()` to retrieve and parse the most recent telemetry.

#### [pubspec.yaml](file:///C:/Users/ramar/StudioProjects/Mobile-PlantEmoji/pubspec.yaml)
- Add the `http` package for networking.

---

### UI Enhancements

#### [main.dart](file:///C:/Users/ramar/StudioProjects/Mobile-PlantEmoji/lib/main.dart)
- Convert `TamagotchiDashboard` to a `StatefulWidget`.
- Add a periodic timer to fetch sensor data.
- Add a "Live Status" panel to the dashboard to display the fetched values.
- Implement visual indicators (e.g., color changes or icons) based on sensor thresholds (e.g., low soil moisture).

---

## Verification Plan

### Automated Tests
- Run `flutter test` (after creating a basic unit test for `SensorData.fromJson`).
- Command: `flutter test test/sensor_data_test.dart`

### Manual Verification
- Run the app on a connected device/emulator.
- Observe the "Live Status" panel to see if it updates with data.
- If the Vercel URL is active, verify that the data matches the expected format.
- If the URL is not yet available, I will implement a "Mock Mode" for testing.
