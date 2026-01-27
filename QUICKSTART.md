# Quick Start Guide

## 🚀 Chạy dự án ngay lập tức

### Bước 1: Di chuyển vào thư mục dự án
```bash
cd C:\Users\ACER\.gemini\antigravity\scratch\my_flutter_app
```

### Bước 2: Kiểm tra Flutter
```bash
flutter doctor
```

### Bước 3: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 4: Chạy ứng dụng
```bash
flutter run
```

## 📱 Chọn thiết bị

Nếu có nhiều thiết bị:
```bash
# Xem danh sách thiết bị
flutter devices

# Chạy trên thiết bị cụ thể
flutter run -d <device-id>

# Chạy trên Chrome
flutter run -d chrome

# Chạy trên Windows
flutter run -d windows
```

## 🎯 Tính năng hiện có

✅ Home Screen với counter app
✅ Custom widgets (Button, TextField, Loading)
✅ Utilities (Snackbar, DateTime)
✅ Example API Service
✅ Example User Model
✅ Constants management
✅ Full documentation

## 📖 Đọc thêm

- [README.md](../README.md) - Tổng quan dự án
- [GETTING_STARTED.md](GETTING_STARTED.md) - Hướng dẫn chi tiết
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Cấu trúc dự án
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Setup Android & iOS

## 🆘 Gặp vấn đề?

### Lỗi thường gặp

**1. Flutter command not found**
```bash
# Thêm Flutter vào PATH
# Hoặc cài đặt lại Flutter
```

**2. Dependencies error**
```bash
flutter clean
flutter pub get
```

**3. Build error**
```bash
# Android
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get

# iOS
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## 💻 IDE khuyến nghị

- **VS Code** + Flutter extension
- **Android Studio** + Flutter plugin
- **IntelliJ IDEA** + Flutter plugin

Happy Coding! 🎉
