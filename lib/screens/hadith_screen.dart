import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_theme.dart';
import '../services/notification_service.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<Map<String, dynamic>> _hadiths = [];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/data/hadiths.json').then((value) {
      final list = (jsonDecode(value) as List).cast<Map<String, dynamic>>();
      final day = DateTime.now().difference(DateTime(2026)).inDays.abs();
      if (mounted) {
        setState(() {
          _hadiths = list;
          _index = day % list.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hadith = _hadiths.isEmpty ? null : _hadiths[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Hadith of the Day')),
      body: hadith == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.emerald,
                        AppColors.emeraldDark.withValues(alpha: .95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.format_quote_rounded,
                          color: AppColors.gold, size: 42),
                      Text(
                        'Daily verified reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          hadith['arabic'].toString(),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 26,
                            height: 1.9,
                          ),
                        ),
                        const Divider(height: 30),
                        Text(
                          hadith['english'].toString(),
                          style: const TextStyle(height: 1.65),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          hadith['reference'].toString(),
                          style: const TextStyle(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Share.share(
                    '${hadith['english']}\n\n${hadith['reference']}',
                  ),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Hadith'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await NotificationService().scheduleDailyHadith();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Daily Hadith reminder enabled.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Daily reminder at 9:00 AM'),
                ),
              ],
            ),
    );
  }
}
