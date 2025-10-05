# [안내] 이 문서는 반드시 workflow_selector.md의 절차를 거쳐 선택된 경우에만 사용하세요.
# 핫픽스 워크플로우 (Hotfix Workflow)

---
## [공통] Workflow 규칙 안내
- 본 파일을 포함한 모든 workflow/rule 파일은 반드시 doc/rules/workflow_common.md(공통 규칙)을 준수해야 함


1. 긴급 이슈 및 영향 범위 파악
2. 최소 단위 수정 및 테스트
3. 코드 분석 및 정적 분석
4. 커밋 및 PR 생성 (긴급 표시)
5. 빠른 리뷰 및 배포

> 핫픽스는 반드시 영향도와 테스트 결과를 명확히 기록
