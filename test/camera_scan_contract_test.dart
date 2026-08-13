import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_smartfarm/api_service.dart';

void main() {
  test('CameraScanResult exposes success and display message', () {
    const result = CameraScanResult(ok: true, message: 'No pests found.');

    expect(result.ok, isTrue);
    expect(result.message, 'No pests found.');
  });
}
