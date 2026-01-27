# 📱 Hướng dẫn Responsive Design cho Flutter

## Tổng quan

Dự án này đã được cấu hình với hệ thống responsive design hoàn chỉnh, hỗ trợ tự động điều chỉnh giao diện cho các thiết bị Android và iOS với kích thước màn hình khác nhau.

## 🎯 Các phương pháp Responsive

### 1. **ScreenUtil Extension** (Khuyến nghị)

Package `flutter_screenutil` cung cấp các extension tiện lợi để tự động scale kích thước.

#### Cài đặt

```yaml
dependencies:
  flutter_screenutil: ^5.9.0
```

#### Khởi tạo trong main.dart

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          home: child,
        );
      },
      child: const HomeScreen(),
    );
  }
}
```

#### Sử dụng

```dart
// Chiều rộng responsive
Container(
  width: 200.w,  // 200 logical pixels
  height: 100.h, // 100 logical pixels
  padding: EdgeInsets.all(16.w),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp), // Responsive font size
  ),
)

// Border radius responsive
BorderRadius.circular(12.r)

// Spacing responsive
SizedBox(height: 20.h, width: 20.w)
```

**Lợi ích:**
- ✅ Tự động scale theo tỷ lệ màn hình
- ✅ Dễ sử dụng với extension methods
- ✅ Hỗ trợ split screen mode
- ✅ Tương thích với cả Android và iOS

---

### 2. **ResponsiveUtils Class**

Utility class tự tạo để kiểm tra loại thiết bị và breakpoints.

#### Breakpoints chuẩn

```dart
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px
```

#### Sử dụng

```dart
import 'package:my_flutter_app/utils/responsive_utils.dart';

// Kiểm tra loại thiết bị
if (ResponsiveUtils.isMobile(context)) {
  // Mobile layout
} else if (ResponsiveUtils.isTablet(context)) {
  // Tablet layout
} else {
  // Desktop layout
}

// Kiểm tra orientation
if (ResponsiveUtils.isLandscape(context)) {
  // Landscape mode
}

// Tính toán theo phần trăm
double width = ResponsiveUtils.widthPercent(context, 80); // 80% màn hình
double height = ResponsiveUtils.heightPercent(context, 50); // 50% màn hình
```

---

### 3. **ResponsiveBuilder Widget**

Widget tự động chọn layout phù hợp dựa trên kích thước màn hình.

#### Sử dụng

```dart
import 'package:my_flutter_app/utils/responsive_utils.dart';

ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

**Lưu ý:** Nếu không cung cấp `tablet` hoặc `desktop`, sẽ fallback về `mobile`.

---

### 4. **SizeConfig Class**

Class tính toán kích thước dựa trên design reference.

#### Khởi tạo

```dart
import 'package:my_flutter_app/utils/size_config.dart';

@override
Widget build(BuildContext context) {
  SizeConfig.init(context); // Khởi tạo trong build method
  
  return Container(
    width: SizeConfig.getProportionateScreenWidth(200),
    height: SizeConfig.getProportionateScreenHeight(100),
  );
}
```

#### Sử dụng Extension

```dart
import 'package:my_flutter_app/utils/size_config.dart';

Container(
  width: 200.w,  // Responsive width
  height: 100.h, // Responsive height
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp), // Responsive font
  ),
)
```

---

### 5. **MediaQuery (Built-in Flutter)**

Phương pháp cơ bản sử dụng MediaQuery của Flutter.

#### Sử dụng

```dart
// Lấy kích thước màn hình
double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;

// Tính toán theo tỷ lệ
Container(
  width: screenWidth * 0.8,  // 80% chiều rộng
  height: screenHeight * 0.3, // 30% chiều cao
)

// Lấy orientation
Orientation orientation = MediaQuery.of(context).orientation;

// Lấy safe area padding
EdgeInsets padding = MediaQuery.of(context).padding;

// Lấy device pixel ratio
double pixelRatio = MediaQuery.of(context).devicePixelRatio;
```

---

### 6. **LayoutBuilder**

Widget để build UI dựa trên constraints của parent.

#### Sử dụng

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      // Tablet/Desktop layout
      return GridView.count(
        crossAxisCount: 3,
        children: items,
      );
    } else {
      // Mobile layout
      return ListView(
        children: items,
      );
    }
  },
)
```

---

## 🎨 Best Practices

### 1. Design Reference

Chọn một kích thước thiết kế chuẩn (thường là iPhone 11 Pro: 375 x 812):

```dart
ScreenUtilInit(
  designSize: const Size(375, 812),
  // ...
)
```

### 2. Responsive Grid

Tự động điều chỉnh số cột dựa trên màn hình:

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _getCrossAxisCount(context),
    crossAxisSpacing: 12.w,
    mainAxisSpacing: 12.h,
  ),
  itemBuilder: (context, index) => GridItem(),
)

int _getCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > 900) return 4; // Desktop
  if (width > 600) return 3; // Tablet
  return 2; // Mobile
}
```

### 3. Responsive Text

```dart
Text(
  'Hello World',
  style: TextStyle(
    fontSize: 16.sp,  // Tự động scale
    fontWeight: FontWeight.bold,
  ),
)
```

### 4. Responsive Padding & Margin

```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 12.h,
  ),
  margin: EdgeInsets.all(8.w),
)
```

### 5. Responsive Border Radius

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
  ),
)
```

---

## 📊 So sánh các phương pháp

| Phương pháp | Độ phức tạp | Linh hoạt | Khuyến nghị |
|-------------|-------------|-----------|-------------|
| ScreenUtil | ⭐ Dễ | ⭐⭐⭐ Cao | ✅ Tốt nhất |
| ResponsiveUtils | ⭐⭐ Trung bình | ⭐⭐⭐ Cao | ✅ Tốt |
| SizeConfig | ⭐⭐ Trung bình | ⭐⭐ Trung bình | ⚠️ OK |
| MediaQuery | ⭐ Dễ | ⭐⭐ Trung bình | ⚠️ Cơ bản |
| LayoutBuilder | ⭐⭐⭐ Khó | ⭐⭐⭐ Cao | ✅ Tốt cho layout phức tạp |

---

## 🚀 Ví dụ thực tế

Xem file `lib/screens/responsive_demo.dart` để xem ví dụ đầy đủ về:
- Thông tin màn hình
- ScreenUtil extensions
- ResponsiveBuilder
- MediaQuery & ResponsiveUtils
- Responsive Grid

### Chạy demo

```bash
flutter run
```

Sau đó nhấn nút **"Xem Responsive Demo"** trên màn hình chính.

---

## 📱 Test trên nhiều thiết bị

### Android

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Android emulator
flutter run -d emulator-5554
```

### iOS (chỉ trên macOS)

```bash
# Open iOS Simulator
open -a Simulator

# Run on iOS
flutter run -d ios
```

### Web (để test responsive nhanh)

```bash
flutter run -d chrome
```

Sau đó sử dụng Chrome DevTools để test các kích thước màn hình khác nhau.

---

## 🎯 Kích thước màn hình phổ biến

### iOS
- **iPhone SE**: 375 x 667
- **iPhone 11 Pro**: 375 x 812
- **iPhone 11 Pro Max**: 414 x 896
- **iPad**: 768 x 1024
- **iPad Pro 12.9"**: 1024 x 1366

### Android
- **Small Phone**: 360 x 640
- **Medium Phone**: 375 x 667
- **Large Phone**: 414 x 896
- **Tablet 7"**: 600 x 960
- **Tablet 10"**: 800 x 1280

---

## 💡 Tips

1. **Luôn test trên thiết bị thật** - Emulator không phản ánh chính xác 100%
2. **Sử dụng ScreenUtil cho hầu hết trường hợp** - Đơn giản và hiệu quả
3. **Kết hợp nhiều phương pháp** - Mỗi phương pháp có điểm mạnh riêng
4. **Chú ý safe area** - Đặc biệt quan trọng cho iPhone có notch
5. **Test cả landscape và portrait** - Đảm bảo UI hoạt động tốt ở cả 2 chế độ

---

## 📚 Tài liệu tham khảo

- [flutter_screenutil package](https://pub.dev/packages/flutter_screenutil)
- [Flutter Responsive Design](https://docs.flutter.dev/ui/layout/responsive)
- [MediaQuery class](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
- [LayoutBuilder class](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)

---

## 🔧 Troubleshooting

### Lỗi: "ScreenUtil not initialized"

**Giải pháp:** Đảm bảo đã wrap MaterialApp trong ScreenUtilInit:

```dart
return ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (context, child) {
    return MaterialApp(
      home: child,
    );
  },
  child: const HomeScreen(),
);
```

### UI bị lỗi trên tablet

**Giải pháp:** Sử dụng ResponsiveBuilder để tạo layout riêng cho tablet:

```dart
ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
)
```

### Text quá nhỏ/lớn

**Giải pháp:** Sử dụng `.sp` extension và điều chỉnh designSize:

```dart
Text('Hello', style: TextStyle(fontSize: 16.sp))
```

---

**Tác giả:** My Flutter App Team  
**Cập nhật:** 2026-01-16
