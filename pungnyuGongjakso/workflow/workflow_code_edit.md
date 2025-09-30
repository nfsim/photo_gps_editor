# [안내] 이 문서는 반드시 workflow_selector.md의 절차를 거쳐 선택된 경우에만 사용하세요.
---
## [공통] Workflow 규칙 안내
- 본 파일을 포함한 모든 workflow/rule 파일은 반드시 doc/rules/workflow_common.md(공통 규칙)을 준수해야 함

## 1. 요구사항 분석 (Requirement Analysis)
- 전달받은 context(이슈, PR, 대화 등)를 기반으로 요구사항 도출
- 기능 목록 작성
- 명확하지 않은 요구사항이나 해석이 필요한 부분은 설계 단계로 넘어가기 전에 정리하여 사용자(또는 담당자)에게 재확인 요청
- 요구사항 분석 및 설계 단계에서는 다음 단계로 넘길 context를 별도의 간결한 markdown 문서로 작성
  - **저장 위치:** `pungnyuGongjakso/memory_bank/`
  - **파일명 규칙:** `issue{이슈번호}_{단계명}.md` (예: `issue45_requirement.md`, `issue45_design.md`)
- 이 markdown에는 다음 단계의 workflow를 진행하기에 충분한 핵심 정보가 반드시 포함되어야 함
- 불필요한 장황한 설명은 지양하고, 명확하고 간결하게 정리

## 2. 설계 (Design)
- 이전 단계(`pungnyuGongjakso/memory_bank/issue{이슈번호}_requirement.md`)의 context를 확인하고, 필요한 정보를 반영
- UX/UI 와이어프레임 및 프로토타입 제작 (필요시, 옵션)
- 시스템 아키텍처 설계 (데이터베이스, API 등)
- 기술 스택 결정
- 설계 단계에서 불명확한 부분은 반드시 사용자(또는 담당자)에게 확인
- 구현 계획 및 주요 코드 구조를 사용자(또는 담당자)에게 먼저 제시하고, 확인 및 피드백을 받은 후 실제 개발 진행
- 설계 단계에서도 구현 단계로 넘길 context를 별도의 간결한 markdown 문서로 작성
  - **저장 위치:** `pungnyuGongjakso/memory_bank/`
  - **파일명 규칙:** `issue{이슈번호}_{단계명}.md` (예: `issue45_requirement.md`, `issue45_design.md`)
- 이 markdown에는 구현 단계의 workflow를 진행하기에 충분한 핵심 정보가 반드시 포함되어야 함
- 불필요한 장황한 설명은 지양하고, 명확하고 간결하게 정리

## 3. 구현 (Development)
- 이전 단계(`pungnyuGongjakso/memory_bank/issue{이슈번호}_design.md`)의 context를 확인하고, 필요한 정보를 반영
- 프론트엔드 개발 (화면, 사용자 인터랙션)
- 백엔드 개발 (서버, 데이터 처리)
- 기능 단위로 모듈화 및 통합
- 구현 단계는 TDD(Test-Driven Development) 방식으로 진행
  - 기능 개발 전 테스트 코드 작성
  - 테스트 통과 후 실제 코드 구현
  - 리팩토링 및 테스트 반복 수행

## 4. 테스트 (Testing)
- 이전 단계(`pungnyuGongjakso/memory_bank/issue{이슈번호}_design.md` 또는 `issue{이슈번호}_development.md`)의 context를 확인하고, 필요한 정보를 반영
- 기능 테스트 (정상 작동 여부 확인)
- 호환성 테스트 (기기 및 OS별)
- 성능 테스트 (속도, 안정성)
- 베타 테스트 (실사용자 피드백 수집)
## 5. 코드 분석 및 정적 분석 (CI Analysis)
- 이전 단계(`pungnyuGongjakso/memory_bank/issue{이슈번호}_development.md` 또는 `issue{이슈번호}_testing.md`)의 context를 확인하고, 필요한 정보를 반영
- CI 환경에서 코드 분석 도구 실행 (예: `flutter analyze`)
- 코드 스타일, 린트, 잠재적 버그 탐지
- 분석 결과 기반 코드 개선
## 6. 커밋 및 PR 생성 (Commit & PR)
- 이전 단계(`pungnyuGongjakso/memory_bank/issue{이슈번호}_ci.md` 등)의 context를 확인하고, 필요한 정보를 반영
- 모든 구현 및 테스트, 분석이 완료되면 변경사항을 커밋
- 커밋 메시지는 명확하고 일관성 있게 작성
- 원격 저장소에 push
- Pull Request(PR) 생성 및 관련 이슈와 연동
- 코드 리뷰 및 피드백 반영