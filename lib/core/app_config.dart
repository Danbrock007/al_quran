class AppConfig {
  // Set with: --dart-define=AI_API_BASE=https://your-domain.com/api
  static const aiApiBase = String.fromEnvironment('AI_API_BASE');
  static const appName = 'Al-Quran';
  static const developerName = 'Muhammad Khurram Saeed';
  static const companyName = 'W3bco';
  static const version = '1.0.0';

  static const quranApi = 'https://api.alquran.cloud/v1';
  static const prayerApi = 'https://api.aladhan.com/v1';
  static const hadithApi = String.fromEnvironment('HADITH_API_BASE');
}

