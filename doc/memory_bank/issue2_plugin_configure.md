# Issue #2 Plugin Configure - Initial Context

## 작업 개요

- **목적**: Core functionality 구현을 위한 essential plugins 설정 (기본 기술 스택 구축의 일부)
- **관련 GitHub Issue**: [#2 Technology Stack & Platform Setup](https://github.com/nfsim/photo_gps_editor/issues/2)
- **기초**: doc/project_tasks.md에서 다음 우선순위 작업으로 선정됨
- **진행 방식**: workflow_development.md 따라 진행 (공통 규칙 포함)
- **Branch**: feature/plugin-configure (origin/main 기반)

## 요구사항

- pubspec.yaml에 필수 플러그인 추가:
  - `image_picker`: 사진 선택 기능
  - `exif`: Exif 메타데이터 추출
  - `google_maps_flutter`: 지도 표시 기능
  - 기타 필요한 플랫폼별 권한 처리 플러그인

- 플랫폼별 권한 설정 (Android/iOS)
- Google Maps API 키 구성 (필요시)
- 기본 통합 테스트

## 다음 단계 준비

- 설계: 필요한 버전 확인, 호환성 체크
- 구현: pubspec.yaml 수정
- 테스트: Flutter build 확인

## 진행 완료사항 (2025-10-11)

✅ **플러그인 Dependencies 완료**:

- `image_picker: ^1.0.7`: 사진 갤러리/카메라 선택
- `exif: ^3.3.0`: EXIF 메타데이터 추출 (GPS 정보 포함)
- `google_maps_flutter: ^2.6.1`: Google Maps 지도 표시
- `permission_handler: ^11.3.1`: 플랫폼 권한 관리

✅ **Android 권한 구성 완료** (android/app/src/main/AndroidManifest.xml):

- `CAMERA`: 사진 촬영 및 비디오 녹화
- `WRITE_EXTERNAL_STORAGE`: 파일 저장 작업 (API 28 이하)
- `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`: 미디어 파일 읽기 (기존)
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`: 위치 정보 (기존)
- Google Maps API 키 메타데이터 추가 (임시 placeholder)

✅ **iOS 권한 구성 완료** (ios/Runner/Info.plist):

- `NSCameraUsageDescription`: 카메라 접근 설명
- `NSPhotoLibraryUsageDescription`: 사진 라이브러리 읽기 설명 (기존)
- `NSPhotoLibraryAddUsageDescription`: 사진 라이브러리 저장 설명
- `NSLocationWhenInUseUsageDescription`: 앱 사용 중 위치 정보 (기존)
- `NSLocationAlwaysAndWhenInUseUsageDescription`: 항상 위치 정보 (기존)
- GMSApiKey 설정 (임시 placeholder)

✅ **빌드 및 린트 테스트 통과**:

- `flutter analyze`: No issues found
- Google Maps API 키 placeholder로 빌드 성공
- 플랫폼별 권한 설정으로 플러그인 통합 완료

## 다음 단계

이제 Issue #2의 플러그인 설정 및 권한 구성 단계가 완료되었습니다. 다음은:

1. **Core 기능 구현 준비**: 사진 선택, GPS 추출, 지도 표시 구현
2. **테스트 케이스 작성**: 각 플러그인 기능 단위 테스트
3. **환경 설정 가이드**: Google Maps API 키 발급 및 설정 방법 문서화

Created: 2025-10-05 13:05 KST
Updated: 2025-10-11 04:08 KST
Workflow Step: 플러그인 설정 및 권한 구성 완료, 다음 core 기능 구현 준비
