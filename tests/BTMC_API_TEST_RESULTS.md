# 🎉 KẾT QUẢ TEST API GIÁ VÀNG VIỆT NAM

## ✅ BTMC API - **HOẠT ĐỘNG TỐT**

### Thông tin API
- **URL**: `http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v`
- **Method**: GET
- **Format**: JSON
- **Status**: ✅ HTTP 200
- **Dữ liệu**: 56 loại vàng

### Cấu trúc JSON Response

```json
{
  "DataList": {
    "Data": [
      {
        "@row": "1",                    // Số thứ tự
        "@n_1": "VÀNG MIẾNG SJC",      // Tên loại vàng
        "@k_1": "24k",                  // Karat
        "@h_1": "999.9",                // Hàm lượng
        "@pb_1": "17230000",            // Giá mua vào (VND)
        "@ps_1": "17430000",            // Giá bán ra (VND)
        "@pt_1": "4986",                // Giá thế giới (USD/oz?)
        "@d_1": "25/01/2026 10:35"     // Thời gian cập nhật
      },
      // ... 55 items nữa
    ]
  }
}
```

### Các loại vàng có sẵn (top 10)

1. **QUÀ MỪNG BẢN VỊ VÀNG** (24k, 999.9)
   - Mua: 17,130,000 VND
   - Bán: 17,430,000 VND

2. **VÀNG MIẾNG SJC** (24k, 999.9) ⭐ PHỔ BIẾN
   - Mua: 17,230,000 VND
   - Bán: 17,430,000 VND

3. **VÀNG NGUYÊN LIỆU** (24k, 999.9)
   - Mua: 15,950,000 VND
   - Bán: Không bán lẻ

4. **NHẪN TRÒN TRƠN** (24k, 999.9)
   - Mua: 17,130,000 VND
   - Bán: 17,430,000 VND

5. **BẢN VÀNG ĐẮC LỘC** (24k, 999.9)
   - Mua: 17,130,000 VND
   - Bán: 17,430,000 VND

6. **TRANG SỨC VÀNG 999.9**
   - Mua: 16,820,000 VND
   - Bán: 17,170,000 VND

7. **TRANG SỨC VÀNG 99.9**
   - Mua: 16,800,000 VND
   - Bán: 17,150,000 VND

... và 49 loại khác

---

## ❌ PNJ API - **KHÔNG HOẠT ĐỘNG**

### Thông tin API
- **URL**: `https://api.pnj.io/pnjcomvn/v1/gold-price`
- **Status**: ❌ DNS Resolution Failed
- **Lỗi**: `Failed host lookup: 'api.pnj.io'`

### Nguyên nhân
- Domain `api.pnj.io` không tồn tại hoặc đã ngừng hoạt động
- API có thể đã đổi endpoint hoặc không còn public

### Giải pháp thay thế
1. Scrape trực tiếp từ website PNJ: `https://www.pnj.com.vn/blog/gia-vang/`
2. Sử dụng BTMC API thay thế (đã hoạt động tốt)

---

## 📝 CODE MẪU SỬ DỤNG BTMC API

### Dart/Flutter Code

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BTMCGoldPrice {
  final String name;
  final String karat;
  final String purity;
  final int buyPrice;
  final int sellPrice;
  final String updatedAt;

  BTMCGoldPrice({
    required this.name,
    required this.karat,
    required this.purity,
    required this.buyPrice,
    required this.sellPrice,
    required this.updatedAt,
  });
}

Future<List<BTMCGoldPrice>> getBTMCGoldPrices() async {
  const url = 'http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v';
  
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    final jsonData = json.decode(utf8.decode(response.bodyBytes));
    final data = jsonData['DataList']['Data'] as List;
    
    final prices = <BTMCGoldPrice>[];
    
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final rowNum = (i + 1).toString();
      
      // Fields có pattern @key_N với N là số thứ tự
      final name = item['@n_$rowNum'] ?? '';
      final karat = item['@k_$rowNum'] ?? '';
      final purity = item['@h_$rowNum'] ?? '';
      final buyPrice = int.tryParse(item['@pb_$rowNum'] ?? '0') ?? 0;
      final sellPrice = int.tryParse(item['@ps_$rowNum'] ?? '0') ?? 0;
      final updatedAt = item['@d_$rowNum'] ?? '';
      
      if (name.isNotEmpty && (buyPrice > 0 || sellPrice > 0)) {
        prices.add(BTMCGoldPrice(
          name: name,
          karat: karat,
          purity: purity,
          buyPrice: buyPrice,
          sellPrice: sellPrice,
          updatedAt: updatedAt,
        ));
      }
    }
    
    return prices;
  }
  
  throw Exception('Failed to load gold prices');
}

// Sử dụng
void main() async {
  final prices = await getBTMCGoldPrices();
  
  for (final price in prices) {
    print('${price.name}');
    print('  Mua: ${price.buyPrice / 1000000} triệu VND/lượng');
    print('  Bán: ${price.sellPrice / 1000000} triệu VND/lượng');
    print('  Cập nhật: ${price.updatedAt}');
    print('');
  }
}
```

---

## 💡 KẾT LUẬN & KHUYẾN NGHỊ

### ✅ Nên sử dụng
1. **BTMC API** - Hoạt động tốt, dữ liệu phong phú (56 loại vàng)
2. **Vietcombank Exchange Rate API** - Tỷ giá USD/VND chính xác
3. **Gold Price API** - Giá vàng quốc tế real-time

### ❌ Không khả dụng
1. **PNJ API** - Domain không hoạt động
2. **CafeF API** - Bị bảo vệ, cần authentication
3. **SJC API** - Connection issues

### 📌 Khuyến nghị implement
```dart
// Service chính sử dụng BTMC API
class GoldPriceService {
  static const String btmcUrl = 
    'http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v';
  
  Future<List<BTMCGoldPrice>> getVietnamGoldPrices() async {
    // Implementation ở trên
  }
  
  // Lấy giá vàng SJC cụ thể
  Future<BTMCGoldPrice?> getSJCPrice() async {
    final prices = await getVietnamGoldPrices();
    return prices.firstWhere(
      (p) => p.name.toUpperCase().contains('SJC'),
      orElse: () => prices.first,
    );
  }
}
```

---

## 📊 So sánh các API

| API | Status | Format | Số loại vàng | Cập nhật |
|-----|--------|--------|--------------|----------|
| BTMC | ✅ Tốt | JSON | 56 | Real-time |
| PNJ | ❌ Lỗi | - | - | - |
| CafeF | ⚠️ Bảo vệ | HTML | Nhiều | Real-time |
| SJC | ❌ Lỗi | XML | - | - |

---

## 🎯 NEXT STEPS

1. ✅ Implement BTMC API vào `GoldPriceService`
2. ✅ Parse JSON theo format `@key_N`
3. ✅ Hiển thị dữ liệu trong UI
4. ⏳ (Optional) Implement caching để giảm API calls
5. ⏳ (Optional) Thử reverse engineer CafeF API

---

📅 **Updated**: January 25, 2026  
✍️ **Tested by**: GitHub Copilot  
📍 **Location**: Vietnam
