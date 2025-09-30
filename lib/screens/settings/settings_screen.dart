import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/font_provider.dart';
import '../../providers/theme_provider.dart';
import 'font_settings_screen.dart';
import 'license_screen.dart';
import 'theme_screen.dart';

const String kAppVersion = '1.0.0'; // pubspec.yaml에서 수동 동기화 필요
const String kContactEmail = 'nfsim.dev@gmail.com'; // README.md에서 연동

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _aboutTapCount = 0;

  static const _themeLabels = {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_themeLabels[themeMode] ?? 'System'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Font'),
            subtitle: Text(fontProvider.fontFamily ?? 'System'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FontSettingsScreen()),
              );
            },
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              setState(() {
                _aboutTapCount++;
                if (_aboutTapCount >= 10) {
                  _aboutTapCount = 0;
                  Navigator.pushNamed(context, '/devmode');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('개발자 모드로 진입합니다.')),
                  );
                }
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          ListTile(
            title: const Text('License'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LicenseScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text(kAppVersion),
          ),
          ListTile(
            title: const Text('Contact'),
            subtitle: const Text(kContactEmail),
          ),
        ],
      ),
    );
  }
}
