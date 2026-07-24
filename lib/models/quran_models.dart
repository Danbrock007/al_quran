class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.translation,
    required this.ayahCount,
    required this.revelationType,
  });

  final int number;
  final String name;
  final String englishName;
  final String translation;
  final int ayahCount;
  final String revelationType;

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
        number: json['number'] as int,
        name: json['name'] as String,
        englishName: json['englishName'] as String,
        translation: json['englishNameTranslation'] as String,
        ayahCount: json['numberOfAyahs'] as int,
        revelationType: json['revelationType'] as String,
      );
}

class Ayah {
  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.arabic,
    required this.translation,
    required this.audioUrl,
  });

  final int number;
  final int numberInSurah;
  final String arabic;
  final String translation;
  final String audioUrl;
}

