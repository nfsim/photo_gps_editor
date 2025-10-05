# Issue 45: Developer Mode 메뉴 추가

## 요구사항 분석

- Settings 화면에서 개발자 모드(DeveloperMode) 메뉴를 추가해야 한다.
- 개발자 모드 진입 방법: Settings/Information(About) 타이틀을 10번 탭하면 진입
- 개발자 모드 진입 시, 테마/로케일 설정 가능 (기본값: 시스템 값)
- 진입 시 사용자에게 안내(스낵바 등) 필요
- DevModeScreen은 이미 존재하며, 해당 화면으로 이동

### 기능 목록
1. SettingsScreen의 About 타이틀에 10번 탭 감지 로직 추가
2. 10번 탭 시 DevModeScreen으로 이동 및 안내 메시지 표시
3. DevModeScreen에서 테마/로케일 설정 UI 제공(기본값: 시스템 값)

### 불명확/확인 필요 사항
- DevModeScreen 내 세부 UI/기능(테마/로케일 설정 방식 등)은 설계 단계에서 구체화

---
이 문서는 workflow_code_edit.md의 1단계(요구사항 분석)에 따라 작성됨.
