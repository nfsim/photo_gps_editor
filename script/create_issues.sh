#!/bin/zsh

# Set your repo (e.g., username/repo or org/repo)
REPO="nfsim/photo_gps_editor"

# Issues to create (titles and bodies)
issues=(
  "프로젝트 개요 및 요구사항 정리
- 애플리케이션 명칭 및 주요 대상 사용자 정의
- 사진 파일의 Exif 메타데이터(특히 GPS 정보) 추출 및 관리 요구사항 명시
- 이미지 스캔/파일 수집, Exif 분석, GPS 위치 표시 등 핵심 기능 도출
- 추가 편집 기능(Undo/Redo, 기본 사진 편집 등) 목록 확정
"
  "기술 스택 및 플랫폼 설정
- Flutter 환경 구축 (Android/iOS 프로젝트 초기 셋업)
- 필수 플러그인(image_picker, exif_plugin, google_maps_flutter 등) 설정
- Android: 스토리지, 위치, 카메라 권한 설정
- iOS: Photo Library 및 위치 서비스 권한 설정
- 서버 및 저장소 연동 구조 설계 (Firebase, AWS S3 등)
"
  "UI/UX 디자인 및 프로토타입 구성
- 디자인 목업 및 와이어프레임 작성 (홈, 이미지 선택, 편집, 지도 보기 등)
- iOS/Android 가이드라인 반영 레이아웃 구성
- Flutter 반응형 UI 개발
- 사용자 흐름 최적화 및 프로토타입 제작
"
  "CI/CD 및 자동화 환경 구축
- CI/CD 파이프라인 설계 및 구축 (GitHub Actions 등)
- 자동 빌드, 테스트, 린트, 배포 자동화 설정
- 코드 스타일 가이드 및 정적 분석 도구 적용
- PR 리뷰 및 머지 전략 수립
"
  "이미지 파일 스캔 및 수집
- 장치 내 사진 파일(JPEG, PNG 등) 스캔 및 목록화
- 동적 파일 선택 및 미리보기 UI 개발
- image_picker 등 플러그인 통합
"
  "데이터 관리 및 분석
- Exif 메타데이터 관리 구조 설계
- 데이터 분석 모듈 개발 (GPS 데이터 집계/필터/시각화)
- 데이터 보관 및 업데이트 기능
"
  "Exif 데이터 추출 및 GPS 정보 처리
- Exif 데이터 추출 모듈 개발 (GPS 정보 파싱)
- 데이터 검증 및 오류 처리
"
  "지도 연동 및 위치 표시 기능
- 지도 API 통합 (Google Maps 등)
- 위치 데이터 지도 출력 및 마커/상호작용 기능
"
  "추가 편집 및 히스토리 기능
- 사진 편집(자르기, 회전, 밝기/대비) 기능
- Undo/Redo 기능 구현
"
  "앱 인트로 및 첫 실행 화면 개발
- 인트로 슬라이드 및 첫 실행 Intro 로직 구현
- 아이콘 및 UI 디자인
"
  "보안 및 개인정보 보호
- 데이터 접근 보안 및 개인정보 보호 정책 구현
- 사용자 권한 관리 및 접근 제어
- 사용자 동의서 기능
"
  "개발 일정 및 리스크 관리
- 프로젝트 타임라인 및 마일스톤 수립
- 리스크 분석 및 대응 방안 마련
"
  "테스트 및 디버깅
- 단위 테스트, UI/UX 테스트, 성능 테스트
- 버그 수정 및 최종 디버깅
"
  "배포 및 유지보수
- 앱 스토어 배포 준비 (iOS/Android)
- 문서화 및 사용자 가이드 작성
- 피드백 수렴 및 업데이트 계획
"
)

for issue in "${issues[@]}"; do
  title="$(echo "$issue" | head -n1)"
  body="$(echo "$issue" | tail -n +2)"
  echo "Creating issue: $title"
  gh issue create --repo "$REPO" --title "$title" --body "$body"
done