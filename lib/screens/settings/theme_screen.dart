import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  static const _themeLabels = {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: ListView(
        children: [
          ...ThemeMode.values.map(
            (mode) => ListTile(
              title: Text(_themeLabels[mode]!),
              trailing:
                  themeMode == mode
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
              onTap: () {
                themeProvider.setThemeMode(mode);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
