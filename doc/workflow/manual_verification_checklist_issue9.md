# Issue #9: 사진 GPS 편집 및 Undo/Redo 기능 수동 검증 checklist

아래 항목들을 실제 앱에서 확인하여 GPS 편집 및 Undo/Redo 기능이 정상적으로 작동하는지 검증하세요.

## 기본 기능

- [ ] 사진 선택 후 지도로 이동
- [ ] 지도에 GPS 위치 마커 표시
- [ ] 사진 모델에 GPS 좌표 표시 (콘솔 또는 UI 표시)

## GPS 편집 기능

- [ ] 마커를 탭하여 현재 편집 사진 선택 (마커 탭 이벤트 발생)
- [ ] 지도 빈 공간 탭으로 새로운 GPS 좌표 설정 (마커 위치 변경)
- [ ] GPS 설정 후 currentPhoto 좌표 변경 확인
- [ ] 선택된 사진의 selectedPhotos 리스트에서도 좌표 변화 확인

## Undo/Redo 기능

- [ ] GPS 변경 후 Undo 버튼 활성화
- [ ] Undo 버튼 탭으로 이전 GPS로 복원 (마커 복원)
- [ ] Redo 버튼 탭으로 변경 복원
- [ ] 다중 변경 시 단계별 Undo 동작 (복수 GPS 변경 테스트)
- [ ] 사진 변경 시 Undo/Redo 히스토리 초기화 (canUndo/canRedo false로 리셋)

## UI/UX

- [ ] MapScreen AppBar에 Undo/Redo 아이콘 표시
- [ ] Undo/Redo 버튼 활성화/비활성화 상태 적절
- [ ] 적절한 tooltip 표시 (Undo, Redo)
- [ ] 버튼 탭 시 visual feedback 제공

## 에러 핸들링 및 안전성

- [ ] 현재 사진 선택 없이 GPS 탭 시 무시 (크러시 없음)
- [ ] undo 스택 없을 때 Undo 버튼 비활성화
- [ ] redo 스택 없을 때 Redo 버튼 비활성화
- [ ] 다중 사진 시 각각 히스토리 독립 관리

## 플랫폼 테스트

- [ ] Android 에뮬레이터/기기에서 GPS 탭 동작
- [ ] iOS 시뮬레이터/기기에서 GPS 탭 동작 (bed 실기 확인 필요)
- [ ] 다양한 해상도에서 마커 탭 정확성
- [ ] 지도 줌/움직임 중에도 탭 기능 유지

## 성능

- [ ] 히스토리 스택이 선형 시간만큼만 증가 (과도한 메모리 사용 X)
- [ ] Undo/Redo 시 지도 렌더링 부드러움

## 코드 품질

- [ ] lint 에러 없음 (flutter analyze pass)
- [ ] 단위 테스트 pass
- [ ] 모델/프로바이더/Provider 패턴 준수
- [ ] 네비게이션 및 상태 관리 올바름

## 검증 결과

- 검증자: [이름]
- 검증 일시: [YYYY-MM-DD HH:MM]
- 플랫폼: [Android/iOS]
- 검증 버전: [commit hash or version]
- 결과: [합격/불합격]
- 누락 항목: [없음/있음] - [설명]
- 추가 메모: [상세한 해석, 발견된 버그 등]

## CI/CD 준비

- [ ] 커밋 메시지: "feat: GPS 편집 Undo/Redo 기능 추가 (Issue #9)"
- [ ] 관련 단위 테스트 포함
- [ ] 코드 리뷰 요청
- [ ] Merge 후 프로덕션 영향 검토
