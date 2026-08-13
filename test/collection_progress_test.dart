import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_smartfarm/api_service.dart';

void main() {
  test('CollectionProgress parses the website API response', () {
    final progress = CollectionProgress.fromJson({
      'unlockedIds': ['comfort', 'badge_1', 'story_1'],
      'level': 27,
    });

    expect(progress.unlockedIds, ['comfort', 'badge_1', 'story_1']);
    expect(progress.level, 27);
  });
}
