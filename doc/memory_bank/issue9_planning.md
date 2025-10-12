# Issue #9: 사진 편집 및 히스토리 기능 Planning

---

## [공통] Workflow 규칙 안내

- 본 파일을 포함한 모든 workflow/rule 파일은 반드시 doc/rules/workflow_common.md(공통 규칙)을 준수해야 함

이 파일은 새로운 이슈(기능/개선/버그 등) 진행 시 일관된 설계·구현·테스트 계획을 수립하기 위한 템플릿과 체크리스트입니다.

---

## 0. 실제 이슈 내용 확인 (GitHub MCP/코딩 에이전트 활용)

- 실제 GitHub Issue #9 내용 확인 (MCP 활용)
- 제목: 추가 편집 및 히스토리 기능
- 본문: 사진 편집(자르기, 회전, 밝기/대비) 기능 및 Undo/Redo 기능 구현
- Milestone: 추가 편집 및 히스토리 기능

## 0.5. 기술 조사 결과 (Breaking Change)

- image_picker 라이브러리를 통한 이미지 선택 시 원본 GPS 메타데이터 손실 확인
- 시각 편집(크롭/회전/밝기) 후 파일 저장 시 EXIF GPS 정보 유실 문제 발생
- 결론: GPS 메타 기반 편집 기능 불가, 시각 편집에 집중하거나 EXIF 보존 라이브러리 탐색 필요
- 현재 방향: 시각 편집 기능 우선 구현, 메타데이터 손실 문제 해결 방안 모색

## 0.6. 요구사항 재정의

- image_picker는 삭제 (GPS 메타 손실)
- 필수 지원 기능:
  - 원본 이미지 파일의 GPS 메타정보 읽기
  - 원본 이미지 파일의 GPS 메타정보 수정 및 저장
- 해결 방안 해결:
  - file_picker: 파일 직접 선택으로 원본 접근
  - flutter_exif: GPS EXIF read/write 지원
  - 권한: Android WRITE_EXTERNAL_STORAGE, iOS 사진 라이브러리 권한

---

## 1. 구현 범위 및 방향 (재검토 후 GPS 중심으로 조정)

1. **핵심 기능/요구사항**
   - GPS 정보 편집 기능 강화: 지도 터치로 GPS 수정에 Undo/Redo 히스토리 제공
   - Undo/Redo 스택으로 편집 히스토리 관리 (Command 패턴 사용)
   - GPS 위치 설정/수정의 역사 관리하여 사용자가 이전 상태로 돌아갈 수 있도록 지원
   - 사진 시각편집 기능은 옵셔널로 분리 (후순위 개발 대상, image editing dependencies 불필요)

2. **적용 범위**
   - MapScreen에서 GPS 편집 기능 강화
   - Undo/Redo 버튼 추가로 히스토리 조작 가능

3. **설정/미리보기/UX**
   - MapScreen에 Undo/Redo UI 버튼 추가
   - 지도 터치 후 GPS 설정을 히스토리에 저장

4. **적용/변경 방식**
   - Provider 패턴으로 편집 상태 관리
   - GPS 수정 시 Command 객체 생성 및 스택 저장
   - 메모리 효율적 관리 (히스토리 제한 수 설정)

5. **테스트 환경**
   - Android/iOS 플랫폼 모두 검증
   - 다중 터치와 히스토리 복원 시나리오 테스트

6. **기타**
   - 이미지 처리 의존성은 사용하지 않음 (GPS 메타데이터만 처리)
   - Command 패턴: GPSSetCommand 등 간단한 구현

---

## 2. 결론(요약)

- GPS 편집 기능의 Undo/Redo 히스토리 구현, 사진 시각편집은 옵셔널로 분리하여 프로젝트 범위 축소

---

## 3. Tasks (체크리스트)

- [x] 라이브러리 교체: image_picker 삭제, file_picker 추가
- [x] 권한 설정: Android WRITE_EXTERNAL_STORAGE, iOS 사진 라이브러리 권한 (이미 있음)
- [x] ImageSelectScreen: file_picker 사용, 원본 파일 경로 얻기
- [x] EXIF 유틸: flutter_exif로 GPS 읽기/쓰기 기능 이식 (MethodChannel 사용)
- [x] PhotoModel: GPS 수정 메소드 추가 (withNewGPS)
- [x] MapScreen: GPS 수정 UI 및 Command 히스토리 통합 (draggable marker, undo/redo 버튼)
- [x] PhotoProvider: GPS 수정 액션 및 히스토리 관리 (기존 있음)
- [ ] 단위 테스트 작성 (GPS 읽기/쓰기, Command)
- [ ] 플랫폼별 테스트 및 검증

---

## 4. Inline Q&A (선택)

- Q: 편집 기능의 우선순위는? A: 크롭 > 회전 > 밝기/대비
- Q: 히스토리 저장 방식은? A: 메모리에 Command 객체 리스트로 저장
