# Issue #2 Plugin Configure - Design

## 설계 결과

### 선택된 플러그인 및 버전

- `image_picker: ^1.0.7`: 사진/갤러리 선택 기능, Flutter 공식 추천
- `exif: ^3.3.0`: Exif 메타데이터 읽기/쓰기
- `google_maps_flutter: ^2.6.1`: Google Maps 표시, 최신 안정 버전
- `permission_handler: ^11.3.1`: 플랫폼별 권한 관리

### 플랫폼별 권한 설정

**Android**:

- `android/app/src/main/AndroidManifest.xml`에 권한 추가:
  - `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  - `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  - `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />`
  - `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />`

**iOS**:

- `ios/Runner/Info.plist`에 권한 추가:
  - `NSPhotoLibraryUsageDescription`: 사진 라이브러리 접근
  - `NSLocationWhenInUseUsageDescription`: 위치 정보 활용
  - `NSLocationAlwaysAndWhenInUseUsageDescription`: 항상 위치 정보

### Google Maps 구성

- API 키 관리: 환경별 구성 예정 (안전하게 variables로)
- 기본 지도 설정: GPS 좌표 표시용

### 구현 계획

1. pubspec.yaml dependencies 추가
2. 플랫폼 manifest/plist 수정
3. 기본 import 테스트
4. Flutter doctor/build 확인

### 고려사항

- Flutter SDK 3.7.2 호환성 확인 ✓
- 각 플러그인 documentation 따름
- 최소 권한 원칙 적용
- 테스트: android emulator/ios simulator에서 기본 기능 확인

Created: 2025-10-05 13:06 KST
Workflow Step: 설계 완료, 구현 단계 준비
