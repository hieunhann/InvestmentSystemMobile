# Tests & API Debugging Tools

Folder này chứa các script test và debug cho các API giá vàng.

## 📁 Files

### 1. `test_gold_apis.dart`
Script test cơ bản cho BTMC và PNJ APIs.

**Chạy:**
```bash
dart run tests/test_gold_apis.dart
```

### 2. `debug_btmc.dart`
Debug chi tiết cấu trúc JSON của BTMC API.

**Chạy:**
```bash
dart run tests/debug_btmc.dart
```

### 3. `test_scraping.dart`
Test web scraping từ các website BTMC và PNJ.

**Chạy:**
```bash
dart run tests/test_scraping.dart
```

### 4. `BTMC_API_TEST_RESULTS.md`
Tài liệu chi tiết kết quả test và hướng dẫn sử dụng BTMC API.

## 🚀 Quick Test

Để test nhanh xem API có hoạt động không:

```bash
# Test BTMC API
dart run tests/debug_btmc.dart

# Test tất cả
dart run tests/test_gold_apis.dart
```

## 📊 Kết quả

- ✅ **BTMC API**: Hoạt động tốt (56 loại vàng)
- ❌ **PNJ API**: Không khả dụng (DNS failed)
- ⚠️ **CafeF API**: Cần authentication

## 📝 Notes

Các file test này không được import vào Flutter app chính. Chúng chỉ dùng để:
- Debug API responses
- Test connectivity
- Verify data structure
- Development purposes
