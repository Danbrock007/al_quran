import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'assistant_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'prayer_screen.dart';
import 'quran_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpenTab: (index) => setState(() => _index = index)),
      const QuranScreen(),
      const AssistantScreen(),
      const PrayerScreen(),
      MoreScreen(
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined), label: 'Quran'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined), label: 'Ask AI'),
          NavigationDestination(
              icon: Icon(Icons.mosque_outlined), label: 'Prayer'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'More'),
        ],
      ),
      floatingActionButton: _index == 2
          ? null
          : FloatingActionButton.small(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              onPressed: () => setState(() => _index = 2),
              child: const Icon(Icons.auto_awesome),
            ),
    );
  }
}

