# Hướng dẫn Setup Android & iOS

## Setup Android

### 1. Yêu cầu

- Android Studio
- Android SDK (API level 21 trở lên)
- Java Development Kit (JDK) 11 trở lên

### 2. Cấu hình Android

#### 2.1. Cập nhật Application ID

Mở file `android/app/build.gradle` và thay đổi:

```gradle
android {
    defaultConfig {
        applicationId "com.example.my_flutter_app"  // Thay đổi thành ID của bạn
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### 2.2. Cấu hình App Name

Mở file `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="My Flutter App"  <!-- Tên app hiển thị -->
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

#### 2.3. Thêm Permissions

Trong `android/app/src/main/AndroidManifest.xml`, thêm permissions cần thiết:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet permission -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- Camera permission -->
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <!-- Storage permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <!-- Location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

#### 2.4. Thay đổi App Icon

1. Tạo icon với các kích thước khác nhau:
   - mdpi: 48x48
   - hdpi: 72x72
   - xhdpi: 96x96
   - xxhdpi: 144x144
   - xxxhdpi: 192x192

2. Đặt vào thư mục tương ứng trong `android/app/src/main/res/`

Hoặc sử dụng tool online: https://appicon.co/

#### 2.5. Signing Configuration (cho Release)

Tạo file `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=<alias>
storeFile=<path-to-keystore>
```

Cập nhật `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Build Android

#### Debug APK
```bash
flutter build apk --debug
```

#### Release APK
```bash
flutter build apk --release
```

#### App Bundle (cho Google Play)
```bash
flutter build appbundle --release
```

### 4. Chạy trên thiết bị Android

```bash
# Xem danh sách devices
flutter devices

# Chạy trên device cụ thể
flutter run -d <device-id>

# Chạy trên tất cả devices
flutter run -d all
```

---

## Setup iOS

### 1. Yêu cầu

- macOS
- Xcode 14.0 trở lên
- CocoaPods
- Apple Developer Account (cho deploy lên App Store)

### 2. Cấu hình iOS

#### 2.1. Mở Xcode

```bash
open ios/Runner.xcworkspace
```

#### 2.2. Cập nhật Bundle Identifier

1. Trong Xcode, chọn Runner trong Project Navigator
2. Chọn tab "Signing & Capabilities"
3. Thay đổi Bundle Identifier: `com.example.myFlutterApp`

#### 2.3. Cấu hình App Name

Mở file `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>My Flutter App</string>

<key>CFBundleName</key>
<string>My Flutter App</string>
```

#### 2.4. Thêm Permissions

Trong `ios/Runner/Info.plist`, thêm permissions:

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần truy cập camera để chụp ảnh</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần truy cập thư viện ảnh</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí của bạn</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>Ứng dụng cần truy cập microphone</string>
```

#### 2.5. Thay đổi App Icon

1. Tạo App Icon Set với các kích thước:
   - 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024

2. Sử dụng Xcode:
   - Mở `ios/Runner/Assets.xcassets/AppIcon.appiconset`
   - Kéo thả các icon vào đúng vị trí

Hoặc sử dụng tool: https://appicon.co/

#### 2.6. Cấu hình Deployment Target

Trong Xcode:
1. Chọn Runner target
2. Tab "General"
3. Đặt "Minimum Deployments" (ví dụ: iOS 12.0)

#### 2.7. Signing (cho Release)

1. Trong Xcode, tab "Signing & Capabilities"
2. Chọn Team (cần Apple Developer Account)
3. Xcode sẽ tự động tạo provisioning profile

### 3. Build iOS

#### Debug
```bash
flutter build ios --debug
```

#### Release
```bash
flutter build ios --release
```

#### Archive (cho App Store)
1. Mở Xcode: `open ios/Runner.xcworkspace`
2. Chọn Product > Archive
3. Sau khi archive xong, chọn "Distribute App"

### 4. Chạy trên thiết bị iOS

```bash
# Chạy trên simulator
flutter run -d ios

# Chạy trên device thật
flutter run -d <device-id>
```

---

## Cấu hình chung

### 1. App Version

Cập nhật trong `pubspec.yaml`:

```yaml
version: 1.0.0+1
# Format: <major>.<minor>.<patch>+<build-number>
```

Hoặc khi build:

```bash
flutter build apk --build-name=1.0.1 --build-number=2
flutter build ios --build-name=1.0.1 --build-number=2
```

### 2. Flavors (Development, Staging, Production)

#### Android

Trong `android/app/build.gradle`:

```gradle
android {
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        prod {
            dimension "environment"
        }
    }
}
```

Build với flavor:
```bash
flutter build apk --flavor dev
flutter build apk --flavor prod
```

#### iOS

Tạo schemes trong Xcode cho từng environment.

### 3. ProGuard (Android - Minify code)

Trong `android/app/build.gradle`:

```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

---

## Troubleshooting

### Android

**Lỗi: Gradle build failed**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Lỗi: SDK version**
- Kiểm tra `android/app/build.gradle`
- Đảm bảo minSdkVersion >= 21

### iOS

**Lỗi: CocoaPods**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

**Lỗi: Signing**
- Kiểm tra Apple Developer Account
- Đảm bảo Bundle Identifier là duy nhất
- Kiểm tra Provisioning Profile

**Lỗi: Simulator không khởi động**
```bash
# Mở Simulator
open -a Simulator

# Hoặc reset simulator
xcrun simctl erase all
```

---

## Testing trên thiết bị thật

### Android

1. Bật Developer Options trên điện thoại
2. Bật USB Debugging
3. Kết nối điện thoại qua USB
4. Chạy: `flutter devices`
5. Chạy: `flutter run`

### iOS

1. Kết nối iPhone qua USB
2. Tin tưởng máy tính trên iPhone
3. Trong Xcode, chọn device
4. Chạy: `flutter run`

---

## Deploy lên Store

### Google Play Store

1. Build App Bundle:
   ```bash
   flutter build appbundle --release
   ```

2. File output: `build/app/outputs/bundle/release/app-release.aab`

3. Upload lên Google Play Console

### Apple App Store

1. Mở Xcode: `open ios/Runner.xcworkspace`
2. Product > Archive
3. Distribute App
4. Chọn "App Store Connect"
5. Upload

---

## Resources

- [Android Developer Guide](https://developer.android.com/)
- [iOS Developer Guide](https://developer.apple.com/ios/)
- [Flutter Deployment](https://docs.flutter.dev/deployment)
