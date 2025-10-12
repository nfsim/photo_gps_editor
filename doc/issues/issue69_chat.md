# Issue #69: 지도 Long Press로 GPS 좌표 수동 설정 기능

이슈 제목: feat: 지도 Long Press로 GPS 좌표 수동 설정 기능

본문: 지도에서 Long Press하여 GPS 좌표를 수동으로 설정할 수 있는 기능을 추가합니다. 주요 기능: 지도 Long Press 이벤트, 단일 마커 관리, 기존 마커 제거, GPS 좌표 설정.
---
## 2025-10-12 14:20 (KST)
**USER:**
Issue #69을 확인하고 지도 Long Press 기능 구현을 요청했습니다. 기존 MapScreen에 Long Press 핸들러를 추가하여 GPS 마커를 생성하고 관리하는 기능입니다.

**COPILOT:**
요구사항을 분석하겠습니다. GitHub Issue #69을 확인하고 다음과 같은 기능들이 구현되어야 합니다:
- 지도 Long Press 이벤트 핸들링
- 단일 GPS 마커만 표시
- 기존 마커 자동 제거
- PhotoProvider를 통한 좌표 저장
- UI 피드백 제공

우선 planning 문서를 작성하고 구현을 진행하겠습니다.

## 2025-10-12 14:27 (KST)
**USER:**
planning 문서 작성 완료. 이제 MapScreen에 Long Press 칼백을 추가하고 마커 관리 로직을 구현하겠습니다.

**COPILOT:**
MapScreen에 onLongPress 콜백을 추가하고 다음과 같은 기능을 구현했습니다:
- _onMapLongPress 메소드: LatLng 좌표를 받아 마커 생성
- _manualGpsMarker 변수: 수동 GPS 마커 상태 관리
- 주황색 마커 색상 사용 (hueOrange = 30)
- 마커 터치 시 제거 기능
- PhotoProvider에 GPS 좌표 설정
- UI 피드백 SnackBar 표시

## 2025-10-12 14:35 (KST)
**USER:**
코드를 분석했습니다. flutter analyze에서 에러 없이 통과했으며, 기존 테스트도 모두 통과하고 있습니다. null safety 이슈들은 적절히 해결했습니다.

**COPILOT:**
모든 테스트가 성공했습니다:
- flutter analyze: No issues found
- flutter test: All tests passed (25개 테스트)

특히 새로 작성한 MapScreen 테스트도 모든 항목 통과했습니다.

## 2025-10-12 14:42 (KST)
**USER:**
이슈 #69 기능 구현이 완료되었습니다. 모든 요구사항이 만족되므로 이제 GitHub 이슈를 close하고 PR을 생성할 수 있습니다.

**COPILOT:**
기능 구현 완료:
✅ 지도에서 Long Press 시 마커 생성
✅ 지도상에 하나의 GPS 마커만 표시
✅ 새로운 마커 생성 시 기존 GPS 마커 제거  
✅ 선택된 좌표를 사진 GPS 정보로 설정 가능
✅ UI 피드백 제공 (마커 선택/해제 알림)

커밋 및 PR 생성 단계로 진행하겠습니다.
---
