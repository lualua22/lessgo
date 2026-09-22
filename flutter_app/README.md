# LessGo Flutter App

This is the native Flutter client for LessGo. The existing Express API and database remain the backend.

## Run locally

From this directory:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

`10.0.2.2` points an Android emulator at the host machine. For an iOS simulator, use `http://127.0.0.1:4000/api`. For a physical device, use the host machine's LAN IP and ensure the API is reachable on that network.

The current mobile client includes phone login and signup, persisted sessions, dashboard, native image picking with AI screen-time analysis, verification submission, API-backed challenge creation/join/detail/deletion, stats, profile editing, avatar updates, badge shop, feedback, logout, and account deletion.

Not included yet: native Google/Kakao SDK configuration, challenge edit/approval UI, store billing, and the web-only admin dashboard.

## Android / iOS 가상 기기 실행 (이 Mac)

앱은 `flutter_app` 폴더에서 실행합니다. 저장소 루트의 `android`, `ios` 폴더는 별도 웹 앱용이므로 혼동하지 마세요.

1. API 서버가 꺼져 있으면 별도 터미널에서 실행하고 계속 켜 둡니다. 이미 실행 중이면 중복 실행하지 않습니다.

   ```bash
   cd /Users/lua/lessgo
   npm run server
   ```

2. 앱용 터미널을 열고 패키지를 준비합니다.

   ```bash
   cd /Users/lua/lessgo/flutter_app
   flutter pub get
   ```

3. 원하는 가상 기기를 켭니다.

   **Android (Pixel 7)**

   ```bash
   flutter emulators --launch Pixel_7
   ```

   Android 홈 화면이 나올 때까지 기다린 다음:

   ```bash
   flutter devices
   flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
   ```

   `emulator-5554`는 `flutter devices`에 표시된 실제 Android ID로 바꿉니다. 기기가 바로 종료되면 별도 터미널에서 아래 명령으로 직접 켜고 로그를 확인합니다.

   ```bash
   "$HOME/Library/Android/sdk/emulator/emulator" -avd Pixel_7
   ```

   **iOS (iPhone 17 Pro)**

   ```bash
   open -a Simulator
   ```

   Simulator 메뉴의 **File → Open Simulator → iOS → iPhone 17 Pro**에서 기기를 선택합니다. 이 Mac의 현재 기기를 명령으로 켜려면:

   ```bash
   xcrun simctl boot CBC57A57-A3D6-4D90-9DC4-7A181B1E48BA
   ```

   이미 켜져 있다는 오류는 다시 부팅할 필요가 없다는 뜻입니다. 이어서 앱을 실행합니다.

   ```bash
   flutter run -d CBC57A57-A3D6-4D90-9DC4-7A181B1E48BA --dart-define=API_BASE_URL=http://127.0.0.1:4000/api
   ```

   기기를 새로 만들면 ID가 바뀔 수 있습니다. `flutter devices` 또는 `xcrun simctl list devices available`에서 확인하세요.

두 플랫폼을 동시에 실행하려면 각각 별도 터미널에서 `flutter run`을 실행합니다. 메모리가 부족하거나 느리면 한 기기씩 실행하세요.

실행 중인 터미널에서 `r`은 저장한 Dart 변경 사항 반영(Hot Reload), `R`은 앱 재시작, `q`는 실행 종료, `d`는 앱을 켜 둔 채 터미널 연결 종료입니다.

VS Code에서는 `flutter_app` 폴더를 열고 Flutter/Dart 확장을 설치한 뒤 **Cmd+Shift+P → Flutter: Select Device**로 켜진 기기를 선택할 수 있습니다. 위 터미널 명령은 플랫폼별 API 주소까지 지정합니다.

기기가 안 보이면 `flutter emulators`, `flutter devices`, `flutter doctor -v` 순서로 확인합니다. Android SDK 라이선스 경고는 `flutter doctor --android-licenses`를 실행해 내용을 읽고 직접 동의합니다.

공식 설정 문서: [Android](https://docs.flutter.dev/platform-integration/android/setup), [iOS](https://docs.flutter.dev/platform-integration/ios/setup).
