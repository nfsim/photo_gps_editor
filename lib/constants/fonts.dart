// ignore_for_file: dangling_library_doc_comments

/// 앱에서 사용할 폰트 목록 및 메타데이터 정의
/// 실제 폰트 파일은 assets/fonts/에 직접 추가 필요

class AppFont {
  final String family;
  final String displayName;
  final String? licenseAsset;

  const AppFont({
    required this.family,
    required this.displayName,
    this.licenseAsset,
  });
}

/// 프로젝트에 포함된 폰트 목록 (예시)
const List<AppFont> kAvailableFonts = [
  AppFont(
    family: 'NotoSans',
    displayName: 'Noto Sans',
    licenseAsset: 'assets/fonts/Noto_Sans/OFL.txt',
  ),
  AppFont(
    family: 'NotoSansKR',
    displayName: 'Noto Sans KR',
    licenseAsset: 'assets/fonts/Noto_Sans_KR/OFL.txt',
  ),
  // 추가 폰트는 여기에...
];
