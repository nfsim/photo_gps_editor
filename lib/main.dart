import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'screens/theme_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ScreenListPage(),
    );
  }
}

class ScreenListPage extends StatelessWidget {
  const ScreenListPage({super.key});

  static final List<ScreenItem> screens = [
    ScreenItem('Theme', Icons.palette, ThemeScreen()),
    ScreenItem('Intro', Icons.info_outline, IntroScreen()),
    ScreenItem('Settings', Icons.settings, SettingsScreen()),
    ScreenItem('DevMode', Icons.developer_mode, DevModeScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 목록')),
      body: ListView.separated(
        itemCount: screens.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = screens[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.screen),
                ),
          );
        },
      ),
    );
  }
}

class ScreenItem {
  final String title;
  final IconData icon;
  final Widget screen;
  const ScreenItem(this.title, this.icon, this.screen);
}

// Dummy screens for navigation
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intro Screen')),
      body: const Center(child: Text('Intro Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings Screen')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}

class DevModeScreen extends StatelessWidget {
  const DevModeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DevMode Screen')),
      body: const Center(child: Text('DevMode Screen')),
    );
  }
}
