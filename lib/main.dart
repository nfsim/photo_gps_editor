import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import 'providers/font_provider.dart';
import 'screens/settings/font_settings_screen.dart';
import 'screens/theme_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FontProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [iOS TODO]
    // - iOS에서는 커스텀 폰트 사용 시 Info.plist에 폰트 파일 등록 필요 (Runner > Info.plist > UIAppFonts)
    // - iOS 시뮬레이터/실기기에서 폰트 적용 및 fallback 동작 별도 테스트 필요
    // - 일부 폰트는 iOS에서 미지원/렌더링 차이 발생 가능성 있음
    // - 향후 iOS 전용 폰트 fallback/override 로직 추가 고려
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ScreenListPage(),
      builder: (context, child) {
        final fontProvider = Provider.of<FontProvider>(context);
        final locale = Localizations.localeOf(context);
        final fontFamily = fontProvider.getEffectiveFontFamily(locale);
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.apply(fontFamily: fontFamily),
          ),
          child: child!,
        );
      },
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
    return FontSettingsScreen();
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
