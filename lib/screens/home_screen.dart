import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/preferences_service.dart';
import '../widgets/section_title.dart';
import 'hadith_screen.dart';
import 'qibla_screen.dart';
import 'surah_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _lastSurah = 1;

  @override
  void initState() {
    super.initState();
    PreferencesService().lastSurah().then((value) {
      if (mounted) setState(() => _lastSurah = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 52,
                height: 52,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamu Alaikum',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Al-Quran',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.emeraldDark, AppColors.emerald],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue your journey',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Surah $_lastSurah',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.ink,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahReaderScreen(
                      surahNumber: _lastSurah,
                      surahName: 'Continue reading',
                    ),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continue reading'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('Explore'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _ActionCard(
              icon: Icons.menu_book_rounded,
              title: 'Read Quran',
              subtitle: 'Surah & Para',
              onTap: () => widget.onOpenTab(1),
            ),
            _ActionCard(
              icon: Icons.auto_awesome,
              title: 'Ask AI',
              subtitle: 'With references',
              onTap: () => widget.onOpenTab(2),
            ),
            _ActionCard(
              icon: Icons.explore_outlined,
              title: 'Qibla',
              subtitle: 'Live compass',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QiblaScreen()),
              ),
            ),
            _ActionCard(
              icon: Icons.format_quote_rounded,
              title: 'Daily Hadith',
              subtitle: 'Verified source',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HadithScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionTitle('Ayah for reflection'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Text(
                  'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(height: 1.8, fontFamily: 'serif'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Indeed, with hardship comes ease.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Surah Ash-Sharh 94:6',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.emerald),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
