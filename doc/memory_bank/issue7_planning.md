# Issue #7 Planning Document - Exif Data Extraction & GPS Information Processing

---

## [공통] Workflow 규칙 안내

- 본 파일을 포함한 모든 workflow/rule 파일은 반드시 doc/rules/workflow_common.md(공통 규칙)을 준수해야 함

이 파일은 새로운 이슈(기능/개선/버그 등) 진행 시 일관된 설계·구현·테스트 계획을 수립하기 위한 템플릿과 체크리스트입니다.

---

## 0. 실제 이슈 내용 확인 (GitHub MCP/코딩 에이전트 활용)

- planning.md 작성 전, 반드시 GitHub MCP(Model Context Protocol) 또는 코딩 에이전트 API를 활용해 실제 이슈의 제목/본문/첨부를 확인한다.
- 실제 이슈 내용(요구사항, 예시, 첨부 이미지 등)을 기반으로 planning을 작성한다.
- 현재 상태: MCP 확인 불가, GH CLI로 확인됨 - Exif 데이터 추출 모듈 개발 (GPS 정보 파싱), 데이터 검증 및 오류 처리

---

## 1. 구현 범위 및 방향

**핵심 기능/요구사항**

- Exif 데이터 추출 모듈 개발 (GPS 정보 파싱)
- 데이터 검증 및 오류 처리
- 선택된 사진들의 GPS 정보 추출 및 저장
- PhotoProvider에 GPS 데이터 업데이트

**적용 범위**

- Issue #5에서 선택된 사진들에 대한 EXIF 처리
- GPSLatitude, GPSLongitude 필드 파싱 (DMS to Decimal 변환)
- 촬영 날짜, 기기 정보, 기타 메타데이터 추출
- GPS 없는 사진에 대한 예외 처리

**설정/미리보기/UX**

- EXIF 추출 진행 표시 (로딩 인디케이터)
- GPS 데이터 추출 성공/실패 표시
- GPS 없는 사진에 대한 사용자 안내

**적용/변경 방식**

- exif 플러그인 사용 (이미 설치됨)
- 비동기 처리로 이미지 로딩 성능 최적화
- PhotoProvider의 updatePhotoInfo를 활용한 데이터 저장

**테스트 환경**

- GPS 포함/미포함 사진으로 테스트
- 메모리 사용량 모니터링 (큰 이미지 처리)
- 에러 케이스 테스트 (EXIF 없음, 손상된 파일)

**기타**

- 개인정보 고려: GPS 데이터는 앱 내부에서만 사용
- 성능: 배치 처리로 효율적인 EXIF 추출

---

## 2. 결론(요약)

Issue #7 Exif 데이터 추출 및 GPS 정보 처리 구현, 선택된 사진들의 메타데이터 추출 및 GPS 좌표 파싱 기능 개발

---

## 3. Tasks (체크리스트)

- [x] Exif 추출 서비스 구현 (exif 플러그인 활용)
- [x] GPS 좌표 변환 로직 (DMS to Decimal)
- [x] PhotoProvider에 EXIF 데이터 업데이트 기능 추가
- [x] 로딩 상태 및 진행 표시 UI
- [x] 에러 처리 및 사용자 피드백
- [ ] Unit 테스트 작성
- [ ] 통합 테스트 (사진 선택 후 EXIF 처리 플로우)

---

## 4. Inline Q&A (선택)

- Q: EXIF 데이터가 없는 사진은 어떻게 처리?
- A: 별도 표시하고, GPS 없이 다른 기능 (편집 등) 사용 가능

- Q: 대용량 이미지 처리 시 메모리 문제는?
- A: 이미지 크기 제한과 비동기 배치 처리로 해결

---

이 템플릿을 복사하여 새로운 이슈의 planning.md 파일에 활용하세요.

Created: 2025-10-11 16:24 UTC
