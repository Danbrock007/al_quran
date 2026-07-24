# Al-Quran

A Flutter application for Quran reading and recitation, referenced Islamic
questions, verified daily Hadith, location-based prayer times, Qibla direction,
bookmarks and reminders.

## Included

- Complete Surah directory from the Quran API
- Arabic Uthmani text, English/Urdu translations and ayah audio
- Multiple Qari selection (Alafasy, Abdul Basit and Al-Minshawi)
- Ayah bookmarks, sharing, last-read state and adjustable Arabic text
- Prayer times based on GPS with Hanafi calculation setting
- Prayer notifications and daily Hadith notification
- Sensor-based Qibla compass
- Urdu/English Islamic assistant UI with citation cards
- Light/dark premium design and custom launcher icon
- About information:
  - Developed by Muhammad Khurram Saeed
  - W3bco
  - Version 1.0.0

## First build

Install Flutter stable, then run:

```bash
flutter create --project-name al_quran --org com.w3bco --platforms=android,ios .
python3 tool/configure_platforms.py
flutter pub get
dart run flutter_launcher_icons
flutter run
```

For a release APK:

```bash
flutter build apk --release
```

The project also includes a GitHub Actions workflow. Push it to GitHub and run
**Build Al-Quran**; download `Al-Quran-APK` from the workflow artifacts.

## AI assistant backend

Religious AI must never expose a provider key in the mobile app. Deploy a
server-side RAG endpoint and supply its base URL at build time:

```bash
flutter run --dart-define=AI_API_BASE=https://api.example.com/v1
```

The app sends this JSON to `POST /islamic-assistant/ask`:

```json
{
  "question": "Safar mein namaz ka kya hukam hai?",
  "language": "Urdu",
  "school": "Hanafi"
}
```

Expected response:

```json
{
  "answer": "Referenced answer...",
  "evidence": [
    {
      "label": "Quran",
      "reference": "Surah An-Nisa 4:101",
      "text": "Translation excerpt"
    }
  ],
  "disclaimer": "For a personal ruling, consult a qualified scholar."
}
```

Until a backend is configured, the app deliberately refuses to invent a fatwa
and displays a safe offline message with a general Quran reference.

## Production checklist

1. Have the Quran editions, translations and Hadith catalogue reviewed by
   qualified scholars.
2. Confirm redistribution licences for every Qari audio edition.
3. Build the AI knowledge base only from versioned, approved Quran/Hadith and
   scholarly sources.
4. Add authentication, rate limiting, abuse prevention and answer-review logs
   to the AI backend.
5. Publish a privacy policy covering location, notifications and AI questions.
6. Configure Android signing and Apple signing before store release.
7. Test prayer calculations against the local mosque and let users manually
   adjust minutes and calculation method.

