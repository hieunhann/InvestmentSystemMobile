# Hướng dẫn đóng góp

Cảm ơn bạn đã quan tâm đến việc đóng góp cho dự án này! 🎉

## Quy trình đóng góp

### 1. Fork repository
Fork repository này về tài khoản GitHub của bạn.

### 2. Clone repository đã fork
```bash
git clone https://github.com/your-username/my_flutter_app.git
cd my_flutter_app
```

### 3. Tạo branch mới
```bash
git checkout -b feature/ten-tinh-nang
# hoặc
git checkout -b fix/ten-bug
```

### 4. Cài đặt dependencies
```bash
flutter pub get
```

### 5. Thực hiện thay đổi
- Viết code theo coding style của dự án
- Thêm tests cho các tính năng mới
- Đảm bảo tất cả tests đều pass

### 6. Chạy tests
```bash
flutter test
flutter analyze
```

### 7. Commit thay đổi
```bash
git add .
git commit -m "feat: mô tả ngắn gọn về thay đổi"
```

#### Quy tắc commit message
- `feat:` - Tính năng mới
- `fix:` - Sửa bug
- `docs:` - Cập nhật documentation
- `style:` - Thay đổi formatting, không ảnh hưởng code
- `refactor:` - Refactor code
- `test:` - Thêm hoặc cập nhật tests
- `chore:` - Cập nhật build tasks, package manager configs, etc.

### 8. Push lên GitHub
```bash
git push origin feature/ten-tinh-nang
```

### 9. Tạo Pull Request
- Truy cập repository gốc trên GitHub
- Click "New Pull Request"
- Chọn branch của bạn
- Điền mô tả chi tiết về thay đổi
- Submit pull request

## Coding Standards

### Dart Style Guide
- Tuân theo [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Sử dụng `flutter format` để format code
- Chạy `flutter analyze` để kiểm tra lỗi

### Widget Organization
```dart
// 1. Imports
import 'package:flutter/material.dart';

// 2. Constants
const kPrimaryColor = Color(0xFF6200EE);

// 3. Stateless/Stateful Widgets
class MyWidget extends StatelessWidget {
  // 4. Constructor
  const MyWidget({super.key});
  
  // 5. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Naming Conventions
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `kCamelCase` hoặc `SCREAMING_SNAKE_CASE`
- Private members: `_leadingUnderscore`

## Testing

### Unit Tests
```dart
test('description of test', () {
  // Arrange
  final value = 42;
  
  // Act
  final result = someFunction(value);
  
  // Assert
  expect(result, equals(expectedValue));
});
```

### Widget Tests
```dart
testWidgets('description of widget test', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## Báo cáo Bug

Khi báo cáo bug, vui lòng cung cấp:
- Mô tả chi tiết về bug
- Các bước để tái hiện
- Kết quả mong đợi vs kết quả thực tế
- Screenshots (nếu có)
- Thông tin môi trường (Flutter version, OS, device, etc.)

## Đề xuất tính năng

Khi đề xuất tính năng mới:
- Mô tả rõ ràng tính năng
- Giải thích tại sao tính năng này hữu ích
- Đưa ra ví dụ use cases
- Nếu có thể, đề xuất cách implement

## Code Review

Tất cả pull requests sẽ được review trước khi merge. Reviewer sẽ kiểm tra:
- Code quality và style
- Test coverage
- Documentation
- Performance implications
- Breaking changes

## Câu hỏi?

Nếu có bất kỳ câu hỏi nào, vui lòng:
- Mở issue trên GitHub
- Liên hệ maintainers

Cảm ơn bạn đã đóng góp! 🙏
