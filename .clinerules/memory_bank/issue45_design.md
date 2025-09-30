# Issue 45: Developer Mode 메뉴 추가

## 설계

### 1. SettingsScreen 수정
- About(Information) 타이틀을 GestureDetector로 감싸 10번 탭 시 DevModeScreen으로 이동
- 탭 횟수는 State로 관리(Stateless → Stateful로 변경 필요)
- 진입 시 ScaffoldMessenger로 안내 메시지(SnackBar) 표시

### 2. DevModeScreen
- 이미 존재하는 DevModeScreen을 네비게이션 대상으로 사용
- DevModeScreen 내에서 테마/로케일 설정 UI 제공(드롭다운 등)
- 테마: ThemeProvider 연동, 로케일: 추후 LocaleProvider 등 확장 고려

### 3. 기타
- 기존 SettingsScreen의 구조/레이아웃은 최대한 유지
- 테스트: 10번 탭 시 정상 진입 및 안내 메시지, DevModeScreen 내 테마/로케일 변경 정상 동작 확인

---
이 문서는 workflow_code_edit.md의 2단계(설계)에 따라 작성됨.
