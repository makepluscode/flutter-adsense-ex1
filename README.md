# AdSense Dashboard

AdSense API를 사용하여 광고 수입을 모니터링하는 Flutter 웹 애플리케이션입니다.

## 시작하기 전에

### 필수 요구사항
- Flutter SDK
- Dart SDK
- Google Cloud Project의 OAuth 2.0 Client ID
- AdSense 계정 및 API 접근 권한

### 환경 설정

1. 프로젝트 클론
```bash
git clone [repository-url]
cd [project-name]
```

2. 의존성 설치
```bash
flutter pub get
```

3. web/index.html 생성 및 Client ID 설정
```bash
cp web/index.html.template web/index.html
```

4. web/index.html 파일에서 Client ID 설정 (본인 ID로 변경)
```javascript
var env = {
  GOOGLE_CLIENT_ID: 'YOUR_CLIENT_ID'
};
```

## 개발 환경 실행

```bash
flutter run -d chrome
```

## 주의사항

- `web/index.html` 파일은 .gitignore에 포함되어 있으므로 git에 커밋되지 않습니다.
- 실제 Client ID는 절대로 공개 저장소에 커밋하지 마세요.

## 프로젝트 구조

```
lib/
├── config/
│   └── environment.dart
├── screens/
│   ├── dashboard_screen.dart
│   └── login_screen.dart
├── services/
│   └── auth_client.dart
├── widgets/
│   └── earning_card.dart
└── main.dart
```

## 사용된 기술

- Flutter
- Google Sign In
- Google AdSense API
- HTTP Client

## 문제 해결

- Client ID 관련 오류가 발생하는 경우:
  - web/index.html 파일이 올바르게 생성되었는지 확인
  - Client ID가 올바른 형식인지 확인
  - Google Cloud Console에서 OAuth 2.0 설정 확인

- API 접근 오류가 발생하는 경우:
  - AdSense API 활성화 여부 확인
  - OAuth 동의 화면 설정 확인
  - API 스코프 설정 확인

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.