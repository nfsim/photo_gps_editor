import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/fonts.dart';
import '../../providers/font_provider.dart';
import 'font_license_screen.dart';

class FontSettingsScreen extends StatelessWidget {
  const FontSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    final selectedFont = fontProvider.selectedFont;
    final fontFamily = fontProvider.fontFamily;

    return Scaffold(
      appBar: AppBar(
        title: const Text('폰트 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 미리보기 (3가지 폰트 사이즈)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '가나다 ABCD 1234',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가나다 ABCD 1234',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가나다 ABCD 1234',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40), // 간격을 24→40으로 늘려 드롭다운이 sample text를 가리는 현상 완화
            // 드롭다운
            DropdownButton<String?>(
              value: fontFamily,
              isExpanded: true,
              hint: const Text('폰트 선택'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('시스템 기본'),
                ),
                ...kAvailableFonts.map((font) => DropdownMenuItem<String?>(
                      value: font.family,
                      child: Row(
                        children: [
                          Text(
                            font.displayName,
                            style: TextStyle(fontFamily: font.family),
                          ),
                          if (font.licenseAsset != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            ),
                        ],
                      ),
                    )),
              ],
              onChanged: (value) {
                fontProvider.setFontFamily(value);
              },
            ),
            const SizedBox(height: 16),
            if (selectedFont?.licenseAsset != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FontLicenseScreen(font: selectedFont!),
                    ),
                  );
                },
                child: Text(
                  '폰트 라이선스 정보 보기',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
