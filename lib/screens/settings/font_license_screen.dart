import 'package:flutter/material.dart';
import '../../constants/fonts.dart';

class FontLicenseScreen extends StatelessWidget {
  final AppFont font;
  const FontLicenseScreen({super.key, required this.font});

  Future<String> _loadLicense(BuildContext context) async {
    if (font.licenseAsset == null) return '라이선스 정보 없음';
    try {
      return await DefaultAssetBundle.of(context).loadString(font.licenseAsset!);
    } catch (_) {
      return '라이선스 파일을 불러올 수 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${font.displayName} 라이선스')),
      body: FutureBuilder<String>(
        future: _loadLicense(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(snapshot.data ?? '라이선스 정보 없음'),
            ),
          );
        },
      ),
    );
  }
}
