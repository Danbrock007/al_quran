import 'package:flutter_test/flutter_test.dart';
import 'package:al_quran/core/app_config.dart';
import 'package:al_quran/services/prayer_service.dart';

void main() {
  test('application identity is correct', () {
    expect(AppConfig.appName, 'Al-Quran');
    expect(AppConfig.version, '1.0.0');
  });

  test('Qibla bearing is normalized', () {
    final bearing = PrayerService().qiblaBearing(31.5204, 74.3587);
    expect(bearing, greaterThanOrEqualTo(0));
    expect(bearing, lessThan(360));
  });
}

