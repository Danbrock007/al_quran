import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/quran_models.dart';
import '../services/quran_service.dart';
import 'surah_reader_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<Surah>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = QuranService().getSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Holy Quran',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search Surah',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Surah>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorView(
                  message: snapshot.error.toString(),
                  retry: () => setState(() => _future = QuranService().getSurahs()),
                );
              }
              final surahs = snapshot.data!
                  .where((s) =>
                      s.englishName.toLowerCase().contains(_query.toLowerCase()) ||
                      s.translation.toLowerCase().contains(_query.toLowerCase()) ||
                      s.number.toString() == _query)
                  .toList();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: surahs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.emerald.withValues(alpha: .1),
                        foregroundColor: AppColors.emerald,
                        child: Text('${surah.number}'),
                      ),
                      title: Text(
                        surah.englishName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${surah.translation} • ${surah.ayahCount} Ayat',
                      ),
                      trailing: Text(
                        surah.name,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: AppColors.emerald,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahReaderScreen(
                            surahNumber: surah.number,
                            surahName: surah.englishName,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: retry, child: const Text('Try again')),
            ],
          ),
        ),
      );
}

