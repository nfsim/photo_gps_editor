# Photo GPS Editor (한국어)

## 📖 프로젝트 개요

**앱 명칭:** Photo GPS Editor
**목표:** 사용자가 저장한 사진들의 GPS 정보를 쉽게 검색, 필터링, 수정할 수 있도록 지원
**대상:** 사진 위치 정보를 관리하려는 일반 사용자 및 사진 작가

## 🛠️ 기술 스택 및 도구

- **언어:** Dart (Flutter 프레임워크)
- **추천 IDE:** Visual Studio Code, Android Studio
- **이미지 처리:** flutter_exif_plugin, image
- **지도 API:** google_maps_flutter (Android/iOS), Apple Maps
- **파일 접근:** file_picker, image_picker
- **권한 관리:** Android/iOS 파일 및 위치 권한
- **AI 코딩 어시스턴트:** GitHub Copilot

## 🚀 주요 기능

- **이미지 파일 스캔 및 수집:**
  - 기기/갤러리 내 사진 자동 스캔
  - 디렉토리/촬영 기간별 필터링
  - Exif 메타데이터(특히 GPS) 추출
- **GPS 편집 및 저장:**
  - 지도 화면에서 위치 수정
  - 새로운 좌표를 Exif에 저장
  - 사진 썸네일과 GPS 정보 표시
- **일괄 GPS 수정**
- **데이터 백업 및 복구**
- **사용자 맞춤 기능:** 즐겨찾기, 히스토리 등
- **UI/UX:**
  - 홈: 스캔/필터/최근 편집 버튼
  - 갤러리형 사진 목록 및 GPS 정보
  - 상세/편집 화면: 미리보기, Exif, GPS 편집
  - 지도 화면: 마커, 위치 선택/저장, 확대/축소, 지도 유형 변경
- **보안:**
  - Exif 정보 편집 전 자동 백업
  - GPS/사진 접근 사용자 동의
  - 데이터 암호화/클라우드 연동(옵션)

## 🌐 언어(Language) 선택

- [한국어 README 보기](README.ko.md)
- [View in English](README.en.md)
