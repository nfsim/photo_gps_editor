import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/providers/font_provider.dart';

void main() {
  group('FontProvider', () {
    late FontProvider provider;
    setUp(() {
      provider = FontProvider();
    });

    test('기본값은 시스템 폰트(null)', () {
      expect(provider.fontFamily, isNull);
      expect(provider.selectedFont, isNull);
    });

    test('폰트 변경 및 selectedFont 동작', () {
      provider.setFontFamily('NotoSansKR');
      expect(provider.fontFamily, 'NotoSansKR');
      expect(provider.selectedFont?.family, 'NotoSansKR');
    });

    test('존재하지 않는 폰트 선택 시 selectedFont는 null', () {
      provider.setFontFamily('없는폰트');
      expect(provider.selectedFont, isNull);
    });

    test('resetToDefault() 호출 시 시스템 폰트로 복귀', () {
      provider.setFontFamily('Roboto');
      provider.resetToDefault();
      expect(provider.fontFamily, isNull);
      expect(provider.selectedFont, isNull);
    });
  });
}
