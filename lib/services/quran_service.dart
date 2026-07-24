import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/quran_models.dart';

class QuranService {
  Future<List<Surah>> getSurahs() async {
    final response = await http
        .get(Uri.parse('${AppConfig.quranApi}/surah'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Quran service is temporarily unavailable.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as List)
        .map((item) => Surah.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ayah>> getAyahs(
    int surah, {
    String translationEdition = 'en.sahih',
    String reciterEdition = 'ar.alafasy',
  }) async {
    final editions = 'quran-uthmani,$translationEdition,$reciterEdition';
    final uri = Uri.parse('${AppConfig.quranApi}/surah/$surah/editions/$editions');
    final response = await http.get(uri).timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw Exception('Unable to load this Surah.');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final editionsData = decoded['data'] as List;
    final arabic = (editionsData[0] as Map<String, dynamic>)['ayahs'] as List;
    final translation =
        (editionsData[1] as Map<String, dynamic>)['ayahs'] as List;
    final audio = (editionsData[2] as Map<String, dynamic>)['ayahs'] as List;
    return List.generate(arabic.length, (index) {
      final a = arabic[index] as Map<String, dynamic>;
      final t = translation[index] as Map<String, dynamic>;
      final r = audio[index] as Map<String, dynamic>;
      return Ayah(
        number: a['number'] as int,
        numberInSurah: a['numberInSurah'] as int,
        arabic: a['text'] as String,
        translation: t['text'] as String,
        audioUrl: r['audio']?.toString() ?? '',
      );
    });
  }
}

