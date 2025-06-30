import 'package:flutter/material.dart';
import '../constants/fonts.dart';

/// 폰트 상태를 관리하는 Provider
class FontProvider extends ChangeNotifier {
  /// 현재 선택된 폰트 패밀리 (null이면 시스템 기본)
  String? _fontFamily;

  String? get fontFamily => _fontFamily;

  /// 폰트 변경
  void setFontFamily(String? family) {
    _fontFamily = family;
    notifyListeners();
  }

  /// 현재 선택된 AppFont 객체 반환 (없으면 시스템 기본)
  AppFont? get selectedFont {
    try {
      return kAvailableFonts.firstWhere((f) => f.family == _fontFamily);
    } catch (_) {
      return null;
    }
  }

  /// 시스템 기본으로 리셋
  void resetToDefault() {
    _fontFamily = null;
    notifyListeners();
  }

  /// 현재 locale에 맞는 폰트 패밀리 반환
  String? getEffectiveFontFamily(Locale locale) {
    if (_fontFamily == 'NotoSans') {
      // 한글 환경이면 NotoSansKR로 대체
      if (locale.languageCode == 'ko') {
        return 'NotoSansKR';
      }
      return 'NotoSans';
    }
    if (_fontFamily == 'NotoSansKR') {
      return 'NotoSansKR';
    }
    return null;
  }
}
