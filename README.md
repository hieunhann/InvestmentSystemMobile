
# Xem tất cả thiết bị đang kết nối
flutter devices

# Xem danh sách Android Emulator có sẵn
flutter emulators



🤖 CHẠY TRÊN ANDROID
# Bước 1: Khởi động emulator (cách 1 - từ terminal)
flutter emulators --launch <emulator_id>

# Bước 2: Chạy app
flutter run

# HOẶC chỉ định emulator cụ thể:
flutter run -d emulator-**5554**
-----------------------------------
Cách 2: Khởi động từ Android Studio

Mở Android Studio → Tools → Device Manager → ▶️ Run
Sau đó chạy: flutter run
--------------------------------------



🌐 CHẠY TRÊN WEB
# Chạy trên Chrome
flutter run -d chrome

# Chạy trên Edge
flutter run -d edge

# Chạy trên Web và mở browser mặc định
flutter run -d web-server









## 🔽 BƯỚC 2: TẢI VÀ CÀI ĐẶT FLUTTER

### **A. Tải Flutter SDK**

#### **Trên Windows:**

1. **Tải Flutter:**
   - Vào [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
   - Tải file **flutter_windows_xxx-stable.zip**

2. **Giải nén:**
   ```powershell
   # Giải nén vào thư mục không có khoảng trắng, ví dụ:
   C:\src\flutter
   # KHÔNG giải nén vào: C:\Program Files\
   ```

3. **Thêm Flutter vào PATH:**
   - Mở **Settings** → **System** → **About** → **Advanced system settings**
   - Click **Environment Variables**
   - Trong **User variables**, chọn **Path** → **Edit**
   - Click **New** và thêm đường dẫn: `C:\src\flutter\bin`
   - Click **OK** để lưu

4. **Kiểm tra:**
   ```powershell
   # Mở PowerShell MỚI và chạy:
   flutter --version
   ```

#### **Trên macOS:**

1. **Tải Flutter:**
   ```bash
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_xxx-stable.zip
   unzip flutter_macos_xxx-stable.zip
   ```

2. **Thêm Flutter vào PATH:**
   ```bash
   # Thêm vào ~/.zshrc hoặc ~/.bashrc
   export PATH="$PATH:$HOME/development/flutter/bin"
   
   # Load lại
   source ~/.zshrc
   ```

3. **Kiểm tra:**
   ```bash
   flutter --version
   ```

### **B. Chạy Flutter Doctor**

```powershell
flutter doctor
```

**Giải thích kết quả:**
- ✅ **[✓]** = Đã cài đặt đầy đủ
- ❌ **[✗]** = Chưa cài đặt hoặc có lỗi
- ⚠️ **[!]** = Cài đặt không đầy đủ

**Ví dụ kết quả:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.19.0, on Microsoft Windows 11)
[✗] Android toolchain - develop for Android devices
[✗] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Visual Studio - develop Windows apps
[✓] VS Code (version 1.85.0)
```

---

## 📱 BƯỚC 3: CÀI ĐẶT CÔNG CỤ THEO PLATFORM

### **🤖 A. SETUP CHO ANDROID**

#### **1. Tải và cài Android Studio:**

- Vào [https://developer.android.com/studio](https://developer.android.com/studio)
- Tải **Android Studio** (khoảng 1GB)
- Cài đặt với các tùy chọn mặc định
- ⏱️ **Thời gian:** 15-30 phút

#### **2. Cài đặt Android SDK:**

1. Mở **Android Studio**
2. Click **More Actions** → **SDK Manager**
3. Trong tab **SDK Platforms**, chọn:
   - ✅ **Android 13.0 (Tiramisu)** hoặc phiên bản mới nhất
   - ✅ **Android SDK Platform 33** (hoặc cao hơn)

4. Trong tab **SDK Tools**, chọn:
   - ✅ **Android SDK Build-Tools**
   - ✅ **Android SDK Command-line Tools**
   - ✅ **Android Emulator**
   - ✅ **Android SDK Platform-Tools**

5. Click **Apply** → **OK**
6. ⏱️ **Thời gian:** 10-20 phút

#### **3. Chấp nhận Licenses:**

```powershell
flutter doctor --android-licenses
# Gõ 'y' và Enter cho tất cả các licenses
```

#### **4. Tạo Android Emulator (Giả lập):**

1. Trong Android Studio: **Tools** → **Device Manager**
2. Click **Create Device**
3. Chọn **Phone** → **Pixel 6** (khuyến nghị) → **Next**
4. Chọn **System Image**: **Tiramisu (API 33)** → **Download** (nếu chưa có)
5. Click **Next** → **Finish**
6. ⏱️ **Thời gian tải:** 5-10 phút

#### **5. Cài Flutter Plugin (Tùy chọn):**

1. **Android Studio** → **Settings/Preferences**
2. **Plugins** → Tìm kiếm **"Flutter"**
3. Click **Install** → Restart Android Studio

### **� B. SETUP CHO WEB**

**Không cần cài đặt thêm!** Flutter Web chỉ cần Chrome/Edge.

### **🪟 D. SETUP CHO WINDOWS DESKTOP**

#### **1. Cài Visual Studio 2022:**

- Tải từ [https://visualstudio.microsoft.com/downloads/](https://visualstudio.microsoft.com/downloads/)
- Chọn **Visual Studio Community 2022** (miễn phí)
- Trong installer, chọn workload:
  - ✅ **Desktop development with C++**
- ⏱️ **Thời gian:** 30-60 phút

#### **2. Enable Windows Desktop:**

```powershell
flutter config --enable-windows-desktop
```

---

## 📥 BƯỚC 4: TẢI DỰ ÁN

### **Cách 1: Clone từ Git (nếu có repository)**

```powershell
# Mở PowerShell/Terminal tại thư mục muốn lưu dự án
cd D:\Projects

# Clone dự án
git clone <repository-url>
cd my_flutter_app
```

### **Cách 2: Tải file ZIP**

1. Tải file ZIP từ repository
2. Giải nén vào thư mục: `D:\Projects\my_flutter_app`
3. Mở PowerShell tại thư mục đó

---

## ⚙️ BƯỚC 5: CÀI ĐẶT DEPENDENCIES

```powershell
# Di chuyển vào thư mục dự án
cd D:\Projects\my_flutter_app

# Cài đặt tất cả packages
flutter pub get
```

**Kết quả mong đợi:**
```
Resolving dependencies...
Got dependencies!
```

⏱️ **Thời gian:** 1-3 phút

---

## ▶️ BƯỚC 6: CHẠY DỰ ÁN

### **🎯 A. Kiểm tra thiết bị có sẵn:**

```powershell
flutter devices
```

**Kết quả ví dụ:**
```
1 connected device:

sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 16.0 (API 36)
```

### **🪟 B. Chạy trên Windows:**

```powershell
flutter run -d windows
```

**Hoặc:**
```powershell
flutter run
# Khi được hỏi, gõ số thứ tự của Windows, ví dụ: 1
```

✅ **Ứng dụng sẽ mở trong cửa sổ Windows Desktop**

### **🤖 C. Chạy trên Android:**

---

## 📱 PHẦN 1: CÁCH CHẠY APP ANDROID

### **🚀 A. Chạy trên Android Emulator (Máy ảo)**

#### **Bước 1: Khởi động Emulator**

**Cách 1: Từ Android Studio (Dễ nhất)**
1. Mở **Android Studio**
2. Vào **Tools** → **Device Manager**
3. Tìm emulator đã tạo (ví dụ: "Android Phone")
4. Nhấn nút **▶️ (Play)** bên cạnh tên emulator
5. Đợi **30-60 giây** để emulator khởi động hoàn toàn

**Cách 2: Từ Terminal (Nhanh hơn)**
```powershell
# Xem danh sách emulator có sẵn
flutter emulators

# Khởi động emulator cụ thể
flutter emulators --launch <emulator_id>
```

**💡 Lưu ý:** Lần đầu khởi động có thể mất **1-2 phút**. Các lần sau nhanh hơn.

#### **Bước 2: Mở khóa màn hình Emulator**

Khi emulator khởi động, màn hình sẽ bị khóa:
- **Chuột:** Click và **kéo từ dưới lên** (giống vuốt trên điện thoại thật)
- **Phím tắt:** `Ctrl + P` (Power button) → rồi kéo từ dưới lên

#### **Bước 3: Kiểm tra kết nối**

```powershell
flutter devices
```

**Kết quả mong đợi:**
```
sdk gphone64 x86 64 • emulator-5554 • android-x64 • Android 16.0 (API 36)
```

✅ Nếu thấy emulator → Đã kết nối thành công!

#### **Bước 4: Chạy ứng dụng**

```powershell
# Di chuyển vào thư mục dự án
cd D:\2026_SPR\SWD\my_flutter_app

# Chạy app
flutter run
# Chọn số tương ứng với Android emulator
```

**Hoặc chỉ định emulator cụ thể:**
```powershell
flutter run -d emulator-5554
```

**⏱️ Thời gian:**
- **Build lần đầu:** 3-5 phút (tải dependencies, compile native code)
- **Build lần sau:** 30-60 giây
- **Hot Reload:** 2-5 giây (chỉ nhấn `r` khi app đang chạy)

#### **Bước 5: Xem kết quả**

Sau khi build xong, terminal sẽ hiển thị:
```
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app-debug.apk...
Syncing files to device sdk gphone64 x86 64...

Flutter run key commands:
r Hot reload. 🔥
R Hot restart.
h List all available interactive commands.
q Quit (terminate the application on the device).
```

✨ **App sẽ tự động mở trên emulator!**

---

### **📱 B. Chạy trên Điện thoại Android thật**

#### **Bước 1: Bật Developer Mode trên điện thoại**

1. Mở **Settings** (Cài đặt)
2. Vào **About phone** (Thông tin điện thoại)
3. Tìm **Build number** (Số bản dựng) hoặc **MIUI version** (với Xiaomi)
4. **Nhấn 7 lần liên tục** vào Build number
5. Xuất hiện thông báo: "You are now a developer!" (Bạn đã là nhà phát triển!)

#### **Bước 2: Bật USB Debugging**

1. Quay lại **Settings** → Tìm **Developer options** (Tùy chọn nhà phát triển)
2. Bật **USB debugging** (Gỡ lỗi USB)
3. Bật thêm **Install via USB** (Cài đặt qua USB) nếu có
4. Bật **Disable Permission Monitoring** (Tắt giám sát quyền) để tránh bị hỏi nhiều lần

#### **Bước 3: Kết nối điện thoại vào máy tính**

1. **Cắm cáp USB** từ điện thoại vào máy tính
2. Trên điện thoại sẽ hiện popup:
   ```
   Allow USB debugging?
   The computer's RSA key fingerprint is:
   XX:XX:XX:XX...
   ```
3. **Tích vào:** "Always allow from this computer" (Luôn cho phép từ máy tính này)
4. Nhấn **OK** hoặc **Allow**

**💡 Lưu ý:** 
- Dùng **cáp USB gốc** hoặc cáp hỗ trợ truyền dữ liệu (không phải cáp chỉ sạc)
- Nếu không hiện popup, thử đổi cổng USB hoặc chọn **File Transfer** trong cài đặt USB

#### **Bước 4: Kiểm tra kết nối**

```powershell
flutter devices
```

**Kết quả mong đợi:**
```
Samsung SM-A525F • 1234567890ABCDEF • android-arm64 • Android 13 (API 33)
```

**Nếu không thấy điện thoại:**
```powershell
# Kiểm tra ADB
adb devices

# Nếu trống, restart ADB
adb kill-server
adb start-server
adb devices
```

#### **Bước 5: Chạy ứng dụng**

```powershell
cd D:\2026_SPR\SWD\my_flutter_app
flutter run
# Chọn số tương ứng với điện thoại
```

**⏱️ Thời gian build lần đầu:** 3-5 phút

✅ **App sẽ tự động cài đặt và chạy trên điện thoại!**

---

## 📱 PHẦN 2: SETUP ANDROID EMULATOR (Tạo máy ảo Android)

**⚠️ Chỉ cần làm 1 lần duy nhất! Các lần sau chỉ cần khởi động emulator.**

### **Bước 1: Mở Device Manager trong Android Studio**

1. Mở **Android Studio**
2. Ở màn hình chính, click **3 chấm ⋮** (More Actions)
3. Chọn **Virtual Device Manager**

**Hoặc:**
- Từ menu: **Tools** → **Device Manager**

### **Bước 2: Tạo Device mới**

1. Click nút **Create Device** (hoặc dấu **+** ở góc trên)
2. Màn hình "Select Hardware" sẽ hiện ra

### **Bước 3: Chọn Hardware**

1. Chọn category: **Phone** (đã chọn sẵn)
2. Chọn device model:
   - **Pixel 6** ⭐ (Khuyến nghị - cân bằng giữa hiệu năng và tính năng)
   - **Pixel 8** (Mới nhất)
   - **Pixel 5** (Nhẹ hơn, phù hợp máy yếu)

**💡 Thông tin Pixel 6:**
```
Size: 6.4"
Resolution: 1080 x 2400
Density: 411 dpi
```

3. Click **Next**

### **Bước 4: Chọn System Image (Android version)**

**Quan trọng:** Chọn đúng loại image!

#### **Khuyến nghị: Chọn Google Play x86_64**

| Tên Image | API Level | Nên chọn? |
|-----------|-----------|-----------|
| **Google Play Intel x86_64 Atom System Image** | **API 36** | ✅ **Khuyến nghị** |
| UpsideDownCake | API 34 | ✅ Tốt |
| Tiramisu | API 33 | ✅ Ổn định |
| Pre-Release (bất kỳ) | - | ❌ Không nên |

**Tại sao chọn Google Play x86_64?**
- ✅ **x86_64:** Chạy nhanh trên CPU Intel/AMD
- ✅ **Google Play:** Có Google Play Store để test
- ✅ **API 36:** Phiên bản mới nhất, tương thích tốt
- ❌ **arm64:** Chỉ dành cho Mac M1/M2

#### **Nếu image chưa tải:**

1. Bên cạnh tên image sẽ có nút **Download**
2. Click **Download**
3. Popup "SDK Quickfix Installation" sẽ hiện ra:
   ```
   Downloading x86_64-36_r07.zip (76%): 1.4 / 1.8 GB ...
   ```
4. Đợi tải xong (⏱️ **5-10 phút**, tùy tốc độ mạng)
5. Click **Finish** khi hoàn tất

#### **Sau khi image đã tải:**

1. Chọn image vừa tải (sẽ có dấu ⭐ nếu đã recommended)
2. Click **Next**

### **Bước 5: Verify Configuration**

Màn hình cuối cùng sẽ hiển thị:

```
AVD Name: Pixel 6 API 36
Pixel 6
2400 x 1080: 411 dpi
Android 16.0 x86_64
```

#### **Tùy chỉnh (Optional):**

Click **Show Advanced Settings** để cấu hình chi tiết:

**Graphics:**
- **Hardware - GLES 2.0** ✅ (Nhanh nhất, khuyến nghị)
- Automatic (Tự động chọn)
- Software - GLES 2.0 (Chậm, dùng khi card đồ họa yếu)

**Memory:**
- **RAM:** 2048 MB (Tối thiểu) → **4096 MB** (Khuyến nghị)
- **VM Heap:** 256 MB → **512 MB** (Nếu máy đủ RAM)
- **Internal Storage:** 4096 MB → **8192 MB** (Nếu muốn cài nhiều app test)

**Boot Option:**
- **Quick Boot** ✅ (Khởi động nhanh - lưu trạng thái)
- Cold Boot (Khởi động từ đầu - chậm hơn)

**Emulated Performance:**
- **Multi-Core CPU:** 4 cores (Nếu CPU có nhiều nhân)

3. Click **Finish**

### **Bước 6: Kiểm tra Emulator đã tạo**

Trong **Device Manager**, bạn sẽ thấy emulator mới:

```
┌────────────────────────────────────────┐
│  Pixel 6 API 36                        │
│  Android 16.0 x86_64 | Google Play     │
│  [▶️ Run]  [✏️ Edit]  [🗑️ Delete]      │
└────────────────────────────────────────┘
```

### **Bước 7: Test Emulator**

1. Click **▶️** để khởi động
2. Đợi emulator boot xong (30-60 giây lần đầu)
3. Màn hình Android sẽ hiện lên → ✅ **Thành công!**

---

## 🎯 QUY TRÌNH LÀM VIỆC HÀNG NGÀY VỚI ANDROID

### **Lần đầu (hôm nay):**
```powershell
# 1. Tạo emulator (đã làm ở trên) ✅
# 2. Khởi động emulator
# 3. flutter run
# → Mất 5-10 phút
```

### **Từ lần sau (mỗi ngày):**
```powershell
# 1. Mở Android Studio → Device Manager → ▶️ Run emulator
#    (hoặc: flutter emulators --launch <id>)
# 2. Đợi 30 giây
# 3. flutter run
# → Chỉ mất 1-2 phút!
```

### **Khi đang code (Hot Reload):**
```powershell
# App đang chạy
# 1. Sửa code
# 2. Save (Ctrl+S)
# 3. Nhấn 'r' trong terminal
# → Thay đổi hiện ngay sau 2-5 giây! ⚡
```

---

## 💡 MẸO ANDROID EMULATOR

### **Tăng tốc Emulator:**

1. **Enable Hardware Acceleration:**
   - Cài **Intel HAXM** (cho Intel CPU) hoặc **AMD Hypervisor** (cho AMD)
   - Android Studio sẽ tự đề xuất cài khi setup

2. **Chọn đúng System Image:**
   - ✅ **x86_64** (Nhanh - cho Intel/AMD)
   - ❌ **arm64** (Chậm - chỉ cho Mac M1/M2)

3. **Tăng RAM cho Emulator:**
   - Device Manager → ⚙️ Edit → Advanced Settings
   - RAM: 4096 MB (4GB)

### **Phím tắt Emulator:**

| Phím | Chức năng |
|------|-----------|
| `Ctrl + M` | Mở menu |
| `Ctrl + H` | Home |
| `Ctrl + Backspace` | Back |
| `Ctrl + Up/Down` | Volume |
| `Ctrl + P` | Power button |

### **Giữ Emulator chạy nền:**

- **Không tắt emulator** sau khi xong việc
- Chỉ **minimize** xuống taskbar
- Lần sau chỉ cần click mở lên → Chạy ngay `flutter run` ⚡

---

## ⚠️ TROUBLESHOOTING ANDROID

### **Lỗi: "No devices found"**

**Nguyên nhân:** Emulator chưa khởi động hoặc chưa kết nối

**Giải pháp:**
```powershell
# Kiểm tra emulator đang chạy
flutter devices

# Nếu trống, khởi động emulator
flutter emulators --launch <emulator_id>

# Hoặc mở từ Android Studio
```

### **Lỗi: "Emulator quá chậm"**

**Giải pháp:**
1. Kiểm tra HAXM đã cài chưa:
   - Android Studio → SDK Manager → SDK Tools → Intel x86 Emulator Accelerator
2. Giảm độ phân giải emulator
3. Chọn Pixel 5 thay vì Pixel 8
4. Tăng RAM cho emulator trong Advanced Settings

### **Lỗi: "ANDROID_HOME not found"**

**Giải pháp:**
```powershell
# Set SDK path
flutter config --android-sdk "D:\2026_SPR\SWD\SDK_android"

# Kiểm tra
flutter doctor
```

### **Lỗi: "Gradle build failed"**

**Giải pháp:**
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### **Lỗi: "Emulator không unlock được"**

**Giải pháp:**
- Nhấn `Ctrl + P` (Power button)
- Đợi 5 giây
- Kéo chuột từ dưới lên
- Nếu vẫn không được, restart emulator

---


## 🔥 BƯỚC 7: HOT RELOAD (LÀM VIỆC HIỆU QUẢ)

Khi app đang chạy, bạn có thể chỉnh sửa code và xem thay đổi NGAY LẬP TỨC:

- **Hot Reload:** Nhấn **`r`** trong terminal (giữ nguyên state)
- **Hot Restart:** Nhấn **`R`** trong terminal (reset state)
- **Quit:** Nhấn **`q`**

**Ví dụ workflow:**
1. App đang chạy
2. Sửa text trong [lib/main.dart](lib/main.dart)
3. Nhấn `r` trong terminal
4. ✨ Thay đổi xuất hiện ngay lập tức!

---

## 🚀 BƯỚC 8: BUILD FILE CÀI ĐẶT

### **Android APK (File .apk):**

```powershell
# Build APK
flutter build apk --release

# File được tạo tại:
# build/app/outputs/flutter-apk/app-release.apk
```

📦 **File có thể cài trực tiếp lên Android**

### **Android App Bundle (Cho Google Play):**

```powershell
flutter build appbundle --release

# File được tạo tại:
# build/app/outputs/bundle/release/app-release.aab
```

---

## 🔧 TROUBLESHOOTING (XỬ LÝ LỖI THƯỜNG GẶP)

### **❌ Lỗi: "flutter is not recognized"**

**Nguyên nhân:** Flutter chưa được thêm vào PATH

**Giải pháp:**
- Làm lại bước thêm Flutter vào PATH
- Khởi động lại PowerShell/Terminal
- Kiểm tra: `echo $env:PATH` (Windows) hoặc `echo $PATH` (Mac/Linux)

### **❌ Lỗi: "Android licenses not accepted"**

**Giải pháp:**
```powershell
flutter doctor --android-licenses
```
Gõ `y` cho tất cả

### **❌ Lỗi: "No devices found"**

**Giải pháp:**
- Khởi động Android emulator hoặc kết nối điện thoại Android qua USB

### **❌ Lỗi: "Gradle build failed"**

**Giải pháp:**
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### **❌ App build chậm trên Android**

**Giải pháp:** Chỉnh sửa [android/gradle.properties](android/gradle.properties):
```properties
org.gradle.jvmargs=-Xmx4096M
org.gradle.daemon=true
org.gradle.parallel=true
```

---

## 📊 KIỂM TRA HOÀN TẤT

Chạy lệnh này để kiểm tra tất cả:

```powershell
flutter doctor -v
```

**Kết quả mong muốn:**
```
[✓] Flutter (Channel stable, 3.29.3)
[✓] Android toolchain - develop for Android devices (Android SDK version 36.1.0)
[✓] Android Studio (version 2025.2.3)
[✓] VS Code (version 1.108.1)
[✓] Connected device (1 available)
```

---

## 💡 MẸO VÀ BEST PRACTICES

---

## 💡 MẸO VÀ BEST PRACTICES

### **🎯 Chạy nhiều emulator Android:**
```powershell
# Có thể chạy nhiều emulator cùng lúc để test trên các thiết bị khác nhau

# Terminal 1 - Pixel 6
flutter run -d emulator-5554

# Terminal 2 - Pixel 8 (nếu có emulator khác)
flutter run -d emulator-5556
```

### **⚡ Tăng tốc độ build:**
- **Cache:** `flutter pub cache repair`
- **Clean:** `flutter clean` khi gặp lỗi lạ
- **Upgrade:** `flutter upgrade` để update phiên bản mới

### **📝 IDE khuyến nghị:**
- **VS Code** + Flutter Extension (nhẹ, nhanh)
- **Android Studio** + Flutter Plugin (đầy đủ tính năng)

### **🔍 Debug:**
```powershell
# Xem log chi tiết
flutter run -v

# Xem cấu trúc widget
flutter run --debug
# Nhấn 'w' để mở Widget Inspector
```

---

## ⏱️ TỔNG HỢP THỜI GIAN CÀI ĐẶT

| Bước | Thời gian ước tính |
|------|-------------------|
| Tải Flutter SDK | 5-10 phút |
| Cài Android Studio + SDK | 30-45 phút |
| Tạo Android Emulator | 10-15 phút |
| Setup dự án | 5 phút |
| Build lần đầu | 3-5 phút |
| **TỔNG (Full setup)** | **1-1.5 giờ** |

---

## 📚 TÀI LIỆU THAM KHẢO

### **Flutter Official:**
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter Samples](https://flutter.github.io/samples/)

### **Packages sử dụng:**
- [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) - Responsive design
- [http](https://pub.dev/packages/http) - API calls
- [provider](https://pub.dev/packages/provider) - State management (nếu dùng)

### **Tài liệu dự án:**
- [GETTING_STARTED.md](docs/GETTING_STARTED.md) - Hướng dẫn bắt đầu
- [RESPONSIVE_DESIGN.md](docs/RESPONSIVE_DESIGN.md) - Responsive design chi tiết
- [PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) - Cấu trúc dự án
- [SETUP_GUIDE.md](docs/SETUP_GUIDE.md) - Hướng dẫn setup

---

## 🆘 HỖ TRỢ VÀ CỘNG ĐỒNG

### **Gặp vấn đề?**
1. Chạy `flutter doctor -v` và đọc output
2. Tìm kiếm lỗi trên [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Xem [Flutter Issues](https://github.com/flutter/flutter/issues)

### **Cộng đồng Flutter Việt Nam:**
- Facebook Group: Flutter Vietnam
- Discord: Flutter Community
- Reddit: r/FlutterDev

---

## 📱 RESPONSIVE DESIGN

Dự án này đã được cấu hình với hệ thống responsive design hoàn chỉnh, tự động điều chỉnh giao diện cho các thiết bị Android và iOS với kích thước màn hình khác nhau.

### Các tính năng

✅ **ScreenUtil Extension** - Tự động scale kích thước với `.w`, `.h`, `.sp`  
✅ **ResponsiveBuilder** - Tự động chọn layout (mobile/tablet/desktop)  
✅ **ResponsiveUtils** - Utility methods để kiểm tra thiết bị  
✅ **SizeConfig** - Tính toán kích thước dựa trên design reference  
✅ **MediaQuery** - Hỗ trợ MediaQuery built-in của Flutter

### Xem Demo

Chạy ứng dụng và nhấn nút **"Xem Responsive Demo"** để xem các ví dụ thực tế.

### Tài liệu chi tiết

Xem [RESPONSIVE_DESIGN.md](docs/RESPONSIVE_DESIGN.md) để biết hướng dẫn đầy đủ về:
- Cách sử dụng các phương pháp responsive
- Best practices
- Ví dụ code
- Troubleshooting

### Ví dụ nhanh

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

Container(
  width: 200.w,  // Responsive width
  height: 100.h, // Responsive height
  padding: EdgeInsets.all(16.w),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp), // Responsive font
  ),
)
```

## 🏗️ Cấu trúc dự án

```
my_flutter_app/
├── lib/              # Mã nguồn Dart chính
│   ├── constants/    # Constants (colors, strings, dimensions)
│   ├── screens/      # Các màn hình
│   ├── utils/        # Utility classes (responsive, snackbar)
│   ├── widgets/      # Custom widgets
│   └── main.dart     # Entry point của ứng dụng
├── docs/             # Tài liệu
│   └── RESPONSIVE_DESIGN.md  # Hướng dẫn responsive design
├── test/             # Unit tests và widget tests
├── pubspec.yaml      # Dependencies và cấu hình
└── README.md         # File này
```

## 🔧 Build ứng dụng

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (khuyến nghị cho Google Play)
```bash
flutter build appbundle --release
```

## 🧪 Testing

### Chạy tất cả tests
```bash
flutter test
```

### Chạy test với coverage
```bash
flutter test --coverage
```

## 📚 Tài liệu tham khảo

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter Samples](https://flutter.github.io/samples/)
- [flutter_screenutil](https://pub.dev/packages/flutter_screenutil)

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng tạo pull request hoặc issue.

## 📄 License

Dự án này được phát hành dưới giấy phép MIT.
