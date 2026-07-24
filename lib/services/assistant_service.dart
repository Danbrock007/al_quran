import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/ai_models.dart';

class AssistantService {
  Future<AssistantAnswer> ask({
    required String question,
    required String language,
    required String school,
  }) async {
    if (AppConfig.aiApiBase.isEmpty) {
      return _offlineGuidance(question, language);
    }
    final response = await http
        .post(
          Uri.parse('${AppConfig.aiApiBase}/islamic-assistant/ask'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'question': question,
            'language': language,
            'school': school,
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (response.statusCode != 200) {
      throw Exception('The referenced assistant is temporarily unavailable.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AssistantAnswer(
      answer: data['answer']?.toString() ?? '',
      evidence: ((data['evidence'] as List?) ?? [])
          .map((item) => Evidence.fromJson(item as Map<String, dynamic>))
          .toList(),
      disclaimer: data['disclaimer']?.toString() ??
          'For a personal ruling, consult a qualified scholar.',
    );
  }

  AssistantAnswer _offlineGuidance(String question, String language) {
    final urdu = language == 'Urdu';
    return AssistantAnswer(
      answer: urdu
          ? 'AI backend configure nahi hua. Al-Quran sirf verified references ke saath deeni jawab deta hai; is liye baghair source ke jawab generate nahi kiya gaya.'
          : 'The AI backend is not configured. Al-Quran answers religious questions only with verified evidence, so it will not invent an unsourced response.',
      evidence: const [
        Evidence(
          label: 'Quran',
          reference: 'Surah An-Nahl 16:43',
          text: 'Ask the people of knowledge if you do not know.',
        ),
      ],
      disclaimer: urdu
          ? 'Zaati fatwa ke liye qualified Mufti ya scholar se rabta karein.'
          : 'Consult a qualified Mufti or scholar for a personal ruling.',
    );
  }
}

