# Cấu trúc dự án Flutter

## Tổng quan

Dự án này được tổ chức theo cấu trúc feature-first, giúp dễ dàng mở rộng và bảo trì.

## Cấu trúc thư mục

```
my_flutter_app/
├── android/                    # Mã nguồn Android native
│   ├── app/
│   │   ├── src/
│   │   └── build.gradle       # Cấu hình build Android
│   └── gradle/
│
├── ios/                        # Mã nguồn iOS native
│   ├── Runner/
│   │   ├── Info.plist         # Cấu hình iOS
│   │   └── Assets.xcassets/   # Assets iOS
│   └── Podfile                # Dependencies iOS
│
├── lib/                        # Mã nguồn Dart chính
│   ├── constants/             # Các hằng số toàn cục
│   │   ├── app_colors.dart    # Màu sắc
│   │   ├── app_strings.dart   # Chuỗi ký tự
│   │   └── app_dimensions.dart # Kích thước, padding, margin
│   │
│   ├── models/                # Data models
│   │   └── (Các model class)
│   │
│   ├── screens/               # Các màn hình
│   │   ├── home_screen.dart
│   │   └── (Các screen khác)
│   │
│   ├── widgets/               # Các widget tái sử dụng
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_overlay.dart
│   │
│   ├── services/              # Services (API, Database, etc.)
│   │   └── (Các service class)
│   │
│   ├── utils/                 # Utility functions
│   │   ├── snackbar_utils.dart
│   │   └── datetime_utils.dart
│   │
│   └── main.dart              # Entry point của app
│
├── assets/                    # Assets (images, fonts, etc.)
│   ├── images/               # Hình ảnh
│   └── fonts/                # Font chữ
│
├── test/                      # Unit tests và widget tests
│   └── widget_test.dart
│
├── .gitignore                # Git ignore file
├── .gitattributes            # Git attributes
├── pubspec.yaml              # Dependencies và cấu hình
├── README.md                 # Tài liệu dự án
├── CONTRIBUTING.md           # Hướng dẫn đóng góp
├── CHANGELOG.md              # Lịch sử thay đổi
└── LICENSE                   # Giấy phép
```

## Hướng dẫn sử dụng

### 1. Constants (lib/constants/)

Chứa các hằng số được sử dụng trong toàn bộ ứng dụng:

- **app_colors.dart**: Định nghĩa màu sắc
- **app_strings.dart**: Định nghĩa chuỗi ký tự (hỗ trợ đa ngôn ngữ)
- **app_dimensions.dart**: Định nghĩa kích thước, padding, margin

```dart
// Sử dụng
import 'package:my_flutter_app/constants/app_colors.dart';

Container(
  color: AppColors.primary,
  padding: EdgeInsets.all(AppDimensions.paddingMedium),
)
```

### 2. Models (lib/models/)

Chứa các data model class:

```dart
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

### 3. Screens (lib/screens/)

Chứa các màn hình chính của ứng dụng. Mỗi screen nên:
- Là một StatefulWidget hoặc StatelessWidget
- Có tên kết thúc bằng `Screen`
- Tập trung vào UI logic

```dart
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
```

### 4. Widgets (lib/widgets/)

Chứa các widget tái sử dụng:
- **custom_button.dart**: Button với style nhất quán
- **custom_text_field.dart**: Text field với validation
- **loading_overlay.dart**: Loading indicator

```dart
// Sử dụng
CustomButton(
  text: 'Đăng nhập',
  onPressed: () {},
  icon: Icons.login,
)
```

### 5. Services (lib/services/)

Chứa các service class để xử lý business logic:
- API calls
- Database operations
- Authentication
- Local storage

```dart
class ApiService {
  static const String baseUrl = 'https://api.example.com';

  Future<List<User>> getUsers() async {
    // API call logic
  }
}
```

### 6. Utils (lib/utils/)

Chứa các utility functions:
- **snackbar_utils.dart**: Hiển thị snackbar
- **datetime_utils.dart**: Format date/time

```dart
// Sử dụng
SnackBarUtils.showSuccess(context, 'Thành công!');
String formattedDate = DateTimeUtils.formatDate(DateTime.now());
```

## Best Practices

### Naming Conventions

- **Files**: snake_case (ví dụ: `home_screen.dart`)
- **Classes**: PascalCase (ví dụ: `HomeScreen`)
- **Variables/Functions**: camelCase (ví dụ: `userName`)
- **Constants**: kCamelCase hoặc SCREAMING_SNAKE_CASE

### Code Organization

1. **Imports**: Nhóm theo thứ tự
   ```dart
   // Dart imports
   import 'dart:async';
   
   // Flutter imports
   import 'package:flutter/material.dart';
   
   // Package imports
   import 'package:intl/intl.dart';
   
   // Project imports
   import 'package:my_flutter_app/constants/app_colors.dart';
   ```

2. **Widget Structure**:
   ```dart
   class MyWidget extends StatelessWidget {
     // 1. Constructor
     const MyWidget({super.key});
     
     // 2. Build method
     @override
     Widget build(BuildContext context) {
       return Container();
     }
     
     // 3. Helper methods (private)
     Widget _buildSomething() {
       return Container();
     }
   }
   ```

### State Management

Hiện tại dự án sử dụng setState. Khi dự án lớn hơn, nên sử dụng:
- Provider
- Riverpod
- BLoC
- GetX

### Testing

Luôn viết tests cho:
- Business logic
- Widgets
- Services

```dart
testWidgets('Counter increments', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('0'), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  
  expect(find.text('1'), findsOneWidget);
});
```

## Thêm tính năng mới

### Bước 1: Tạo Model (nếu cần)
```dart
// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  
  Product({required this.id, required this.name, required this.price});
}
```

### Bước 2: Tạo Service (nếu cần)
```dart
// lib/services/product_service.dart
class ProductService {
  Future<List<Product>> getProducts() async {
    // Implementation
  }
}
```

### Bước 3: Tạo Screen
```dart
// lib/screens/product_list_screen.dart
class ProductListScreen extends StatefulWidget {
  // Implementation
}
```

### Bước 4: Tạo Widgets (nếu cần)
```dart
// lib/widgets/product_card.dart
class ProductCard extends StatelessWidget {
  // Implementation
}
```

## Cấu hình Platform-specific

### Android

Cấu hình trong `android/app/build.gradle`:
- minSdkVersion
- targetSdkVersion
- applicationId
- Permissions

### iOS

Cấu hình trong `ios/Runner/Info.plist`:
- Bundle Identifier
- Display Name
- Permissions

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
