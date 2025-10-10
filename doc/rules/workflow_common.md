# Workflow 공통 규칙 (workflow_common.md)

이 문서는 프로젝트 내 모든 workflow 및 rule 파일에서 반드시 준수해야 하는 공통 규칙을 정의합니다.

---

## 1. Branch Management (작업 시작 시 Branch 생성)
- 모든 새로운 작업(기능 추가, 버그 수정 등) 시작 시, `origin/main`을 기반으로 새로운 branch를 생성한다.
- Branch 이름은 `feature/issue#[번호]-[간단한 설명]` 형식으로 명시하며, 관련 이슈 번호를 포함하도록 한다.
- 예: `feature/issue7-exif-gps-processing`

## 2. 대화 및 의사소통 기록
- 모든 workflow 진행 및 의사소통 기록은 반드시 `issue_chat.rule`을 따라 `doc/issues/issueXX_chat.md` 파일에 남긴다.
- 시간, 사용자, Copilot 답변 등은 규칙에 맞게 기록한다.

## 3. 커밋 메시지 및 Git 관리

### 3.1. 커밋 메시지 규칙

- 커밋 메시지는 명확하고 일관된 형식을 따른다. (별도 규칙 파일이 있을 경우 그에 따름)

### 3.2. Git 충돌 방지 전략

#### 3.2.1. 프리 커밋 전략

- **main 브랜치 최신화 주기**: 최대 **6시간마다** `git fetch origin && git rebase origin/main` 실행
- **커밋 빈도**: 대량 변경 시 분할 커밋으로 atomic 단위 유지
- **브랜치 생명주기**: 동일 issue에 **1개 브랜치만** 운영, 콘플릭트 시 즉시 해결

#### 3.2.2. 푸시 규칙

- **푸시 빈도 제한**: 최대 **1일**/1회 푸시를 원칙으로 전방향 테스트 후 실시
- **브랜치별 역할분담**: feature 브랜치는 기능 개발 전용, main 브랜치는 배포 전용

#### 3.2.3. 도구 활용

- `git status --ahead-behind` 명령어로 브랜치 상태 사전 확인
- conflict 발생시 즉각 팀원 공유 및 협력 solve

## 4. PR(Pull Request) 생성 및 충돌 대응

### 4.1. PR 생성 규칙

- PR 생성 시 템플릿을 사용하고, 변경 요약/테스트 결과/관련 이슈를 명확히 작성한다.
- `gh pr checks <PR_NUMBER>`로 PR 충돌 상태 사전 모니터링

### 4.2. 충돌 발생시 대응 프로토콜

```
🚨 CONFLICT 감지시:
1. 즉시 작업 일시정지
2. git stash (작업 중 코드 임시 저장)
3. git fetch origin && git rebase origin/main
4. 충돌 파일 수동 해결 (커밋별 diff 참조)
5. git continue (또는 --skip/--abort)
6. 작업 재개
```

## 5. 문서화
- 모든 주요 변경점, 결정, 논의 결과는 관련 문서(README, 설계서 등)에 반영한다.

## 6. 테스트 및 검증
- 기능/버그/개선 작업 시 반드시 테스트를 작성하고, 결과를 기록한다.

## 7. 코드 리뷰
- 모든 PR은 최소 1인 이상의 리뷰를 거쳐야 하며, 리뷰 의견은 기록으로 남긴다.

## 8. 보안 및 개인정보
- 코드/문서/이슈/PR 등 모든 기록에 개인정보 및 민감정보가 포함되지 않도록 주의한다.

---

> 본 문서는 모든 workflow 및 rule 파일에서 참조되어야 하며, 개별 파일에는 "공통 규칙(workflow_common.md)을 반드시 준수한다"는 문구를 명시한다.
