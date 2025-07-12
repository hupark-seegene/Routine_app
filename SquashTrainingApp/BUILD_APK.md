# APK 빌드 가이드

## 사전 요구사항

### Java 설치 필요
APK 빌드를 위해서는 Java JDK가 필요합니다:

1. JDK 11 이상 설치 (권장: JDK 17)
   - Windows: https://adoptium.net/ 에서 다운로드
   - Linux: `sudo apt install openjdk-17-jdk`
   - Mac: `brew install openjdk@17`

2. JAVA_HOME 환경변수 설정:
   ```bash
   export JAVA_HOME=/path/to/java
   export PATH=$JAVA_HOME/bin:$PATH
   ```

## 개발용 APK 빌드 (현재 설정)

1. 프로젝트 루트에서 다음 명령어 실행:
```bash
cd android
./gradlew clean
./gradlew assembleRelease
```

2. 생성된 APK 위치:
```
android/app/build/outputs/apk/release/app-release.apk
```

## 프로덕션 APK 빌드 (권장)

프로덕션 배포를 위해서는 자체 서명 키를 생성해야 합니다:

1. 서명 키 생성:
```bash
keytool -genkeypair -v -keystore squash-training-release-key.keystore -alias squash-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

2. `android/gradle.properties`에 추가:
```
SQUASH_RELEASE_STORE_FILE=squash-training-release-key.keystore
SQUASH_RELEASE_KEY_ALIAS=squash-key-alias
SQUASH_RELEASE_STORE_PASSWORD=your_password
SQUASH_RELEASE_KEY_PASSWORD=your_password
```

3. `android/app/build.gradle` 수정:
```gradle
signingConfigs {
    release {
        if (project.hasProperty('SQUASH_RELEASE_STORE_FILE')) {
            storeFile file(SQUASH_RELEASE_STORE_FILE)
            storePassword SQUASH_RELEASE_STORE_PASSWORD
            keyAlias SQUASH_RELEASE_KEY_ALIAS
            keyPassword SQUASH_RELEASE_KEY_PASSWORD
        }
    }
}
```

4. APK 빌드:
```bash
cd android
./gradlew clean
./gradlew assembleRelease
```

## APK 설치

생성된 APK를 안드로이드 기기에 설치:
1. 기기의 '설정 > 보안'에서 '알 수 없는 출처' 허용
2. APK 파일을 기기로 전송
3. 파일 관리자에서 APK 실행하여 설치

## 주의사항
- 현재 설정은 debug.keystore를 사용하므로 개발/테스트용입니다
- Google Play Store 배포를 위해서는 반드시 자체 서명 키를 생성하세요
- 서명 키와 비밀번호는 안전하게 보관하세요