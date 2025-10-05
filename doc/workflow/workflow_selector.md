# 워크플로우 선택 (Workflow Selector)

---
## [공통] Workflow 규칙 안내
- 본 파일을 포함한 모든 workflow/rule 파일은 반드시 doc/rules/workflow_common.md(공통 규칙)을 준수해야 함


## 절차
1. 사용자의 input(이슈, PR, 명령 등) 수집
2. input의 유형 및 목적 분석
3. 아래 기준에 따라 워크플로우 파일 선택
    - 기능 추가/버그 수정/일반 개발: `workflow_development.md`
    - 문서 작성/수정: `workflow_documentation.md`
    - 긴급 패치: `workflow_hotfix.md`
4. 선택된 워크플로우 파일의 절차에 따라 진행

> 선택된 워크플로우 파일의 내용을 context로 넘겨 다음 단계에서 활용

## Github Issue 연동
- 사용자의 input이 issue 번호일 경우, 해당 Github issue의 내용을 조회하여 input context로 활용
- issue의 제목, 본문, 라벨 등도 워크플로우 선택 및 context 분석에 반영
