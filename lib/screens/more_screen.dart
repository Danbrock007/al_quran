import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import 'hadith_screen.dart';
import 'qibla_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Text(
          'More',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                value: darkMode,
                onChanged: onDarkModeChanged,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
              ),
              ListTile(
                leading: const Icon(Icons.explore_outlined),
                title: const Text('Qibla compass'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QiblaScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.format_quote_rounded),
                title: const Text('Daily Hadith'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HadithScreen()),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.bookmark_outline),
                title: Text('Bookmarks'),
                subtitle: Text('Saved locally on this device'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 82,
                    height: 82,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppConfig.appName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text('Quran • Hadith • Prayer • Referenced guidance'),
                const SizedBox(height: 18),
                const Divider(),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.code, color: AppColors.emerald),
                  title: Text('Developed by'),
                  subtitle: Text(
                    '${AppConfig.developerName}\n${AppConfig.companyName}',
                  ),
                ),
                const Text('Version ${AppConfig.version}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Al-Quran supports learning and reference. For personal fatwas or serious matters, consult a qualified scholar.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
