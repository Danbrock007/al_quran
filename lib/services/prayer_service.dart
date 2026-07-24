import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/prayer_models.dart';

class PrayerService {
  Future<Position> currentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required for prayer times.');
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Please enable location services.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  Future<PrayerTimes> getTimes({
    required double latitude,
    required double longitude,
    int method = 1,
    int school = 1,
  }) async {
    final now = DateTime.now();
    final uri = Uri.parse(
      '${AppConfig.prayerApi}/timings/${now.millisecondsSinceEpoch ~/ 1000}'
      '?latitude=$latitude&longitude=$longitude&method=$method&school=$school',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Unable to calculate prayer times.');
    }
    final root = jsonDecode(response.body)['data'] as Map<String, dynamic>;
    final timings = root['timings'] as Map<String, dynamic>;
    final date = root['date'] as Map<String, dynamic>;
    String clean(String value) => value.split(' ').first;
    return PrayerTimes(
      fajr: clean(timings['Fajr'].toString()),
      sunrise: clean(timings['Sunrise'].toString()),
      dhuhr: clean(timings['Dhuhr'].toString()),
      asr: clean(timings['Asr'].toString()),
      maghrib: clean(timings['Maghrib'].toString()),
      isha: clean(timings['Isha'].toString()),
      hijriDate: (date['hijri'] as Map<String, dynamic>)['date'].toString(),
      gregorianDate:
          (date['gregorian'] as Map<String, dynamic>)['date'].toString(),
    );
  }

  double qiblaBearing(double latitude, double longitude) {
    const kaabaLat = 21.422487;
    const kaabaLng = 39.826206;
    final lat1 = latitude * pi / 180;
    final lat2 = kaabaLat * pi / 180;
    final deltaLng = (kaabaLng - longitude) * pi / 180;
    final y = sin(deltaLng) * cos(lat2);
    final x =
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }
}

