import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../core/app_theme.dart';
import '../services/prayer_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _bearing;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final service = PrayerService();
      final position = await service.currentPosition();
      if (mounted) {
        setState(() => _bearing =
            service.qiblaBearing(position.latitude, position.longitude));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Compass')),
      body: _error != null
          ? Center(child: Text(_error!, textAlign: TextAlign.center))
          : _bearing == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    final heading = snapshot.data?.heading;
                    if (heading == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Text(
                            'Compass sensor is unavailable. Try a physical phone and enable location.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    final rotation = (_bearing! - heading) * pi / 180;
                    final aligned =
                        (((_bearing! - heading + 540) % 360) - 180).abs() < 4;
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            aligned ? 'You are facing Qibla' : 'Turn toward Qibla',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text('${_bearing!.toStringAsFixed(1)}° from North'),
                          const Spacer(),
                          Container(
                            width: 290,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border: Border.all(
                                color: aligned
                                    ? AppColors.gold
                                    : AppColors.emerald.withValues(alpha: .25),
                                width: aligned ? 5 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .08),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: Transform.rotate(
                              angle: rotation,
                              child: const Icon(
                                Icons.navigation_rounded,
                                size: 150,
                                color: AppColors.emerald,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'For accuracy, keep the phone flat and away from metal or electronic equipment. Move it in a figure-eight to calibrate.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

