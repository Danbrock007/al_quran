import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_theme.dart';
import '../models/quran_models.dart';
import '../services/preferences_service.dart';
import '../services/quran_service.dart';

class SurahReaderScreen extends StatefulWidget {
  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });
  final int surahNumber;
  final String surahName;

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  final _audio = AudioPlayer();
  final _preferences = PreferencesService();
  late Future<List<Ayah>> _future;
  Set<String> _bookmarks = {};
  int? _playing;
  double _arabicSize = 30;
  String _translation = 'en.sahih';
  String _reciter = 'ar.alafasy';

  @override
  void initState() {
    super.initState();
    _load();
    _preferences.setLastSurah(widget.surahNumber);
    _preferences.bookmarks().then((value) {
      if (mounted) setState(() => _bookmarks = value);
    });
    _audio.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = null);
    });
  }

  void _load() {
    _future = QuranService().getAyahs(
      widget.surahNumber,
      translationEdition: _translation,
      reciterEdition: _reciter,
    );
  }

  Future<void> _play(Ayah ayah) async {
    if (_playing == ayah.numberInSurah) {
      await _audio.stop();
      setState(() => _playing = null);
      return;
    }
    await _audio.stop();
    await _audio.play(UrlSource(ayah.audioUrl));
    setState(() => _playing = ayah.numberInSurah);
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Translation',
            onSelected: (value) => setState(() {
              _translation = value;
              _load();
            }),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en.sahih', child: Text('English — Sahih')),
              PopupMenuItem(value: 'ur.jalandhry', child: Text('Urdu — Jalandhry')),
            ],
            icon: const Icon(Icons.translate),
          ),
          PopupMenuButton<String>(
            tooltip: 'Reciter',
            onSelected: (value) => setState(() {
              _reciter = value;
              _load();
            }),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'ar.alafasy', child: Text('Mishary Alafasy')),
              PopupMenuItem(value: 'ar.abdulbasitmurattal', child: Text('Abdul Basit')),
              PopupMenuItem(value: 'ar.minshawi', child: Text('Al-Minshawi')),
            ],
            icon: const Icon(Icons.record_voice_over_outlined),
          ),
          IconButton(
            tooltip: 'Text size',
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (context, modalSetState) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Arabic text size',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      Slider(
                        value: _arabicSize,
                        min: 22,
                        max: 48,
                        onChanged: (value) {
                          modalSetState(() => _arabicSize = value);
                          setState(() => _arabicSize = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.text_fields),
          ),
        ],
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final ayah = snapshot.data![index];
              final key = '${widget.surahNumber}:${ayah.numberInSurah}';
              final bookmarked = _bookmarks.contains(key);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor:
                                AppColors.emerald.withValues(alpha: .1),
                            child: Text('${ayah.numberInSurah}'),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _play(ayah),
                            icon: Icon(
                              _playing == ayah.numberInSurah
                                  ? Icons.stop_circle_outlined
                                  : Icons.play_circle_outline,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _preferences.toggleBookmark(key);
                              final values = await _preferences.bookmarks();
                              setState(() => _bookmarks = values);
                            },
                            icon: Icon(bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border),
                          ),
                          IconButton(
                            onPressed: () => Share.share(
                              '${ayah.arabic}\n\n${ayah.translation}\n'
                              '${widget.surahName} ${ayah.numberInSurah}',
                            ),
                            icon: const Icon(Icons.share_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ayah.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: _arabicSize,
                          height: 2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(ayah.translation,
                          style: const TextStyle(height: 1.6)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

