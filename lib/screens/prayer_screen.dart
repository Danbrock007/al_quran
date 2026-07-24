import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/prayer_models.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import 'qibla_screen.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final _service = PrayerService();
  PrayerTimes? _times;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _service.currentPosition();
      final times = await _service.getTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (mounted) setState(() => _times = times);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _currentPrayer(PrayerTimes times) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    var current = 'Isha';
    for (final entry in times.values.entries) {
      if (entry.key == 'Sunrise') continue;
      final parts = entry.value.split(':');
      final minutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (nowMinutes >= minutes) current = entry.key;
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Prayer Times',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        const Text('Calculated for your current location'),
        const SizedBox(height: 18),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(70),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.location_off_outlined, size: 45),
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  FilledButton(onPressed: _load, child: const Text('Try again')),
                ],
              ),
            ),
          )
        else if (_times != null) ...[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.emeraldDark, AppColors.emerald],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current prayer',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text(
                  _currentPrayer(_times!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_times!.gregorianDate} • ${_times!.hijriDate} AH',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._times!.values.entries.map(
            (entry) => Card(
              child: ListTile(
                leading: Icon(
                  entry.key == 'Fajr'
                      ? Icons.wb_twilight
                      : entry.key == 'Maghrib'
                          ? Icons.nights_stay_outlined
                          : Icons.wb_sunny_outlined,
                  color: AppColors.emerald,
                ),
                title: Text(entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                trailing: Text(
                  entry.value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await NotificationService().schedulePrayerNotifications(_times!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prayer reminders scheduled.')),
                );
              }
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Enable prayer reminders'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaScreen()),
            ),
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Open Qibla compass'),
          ),
        ],
      ],
    );
  }
}

