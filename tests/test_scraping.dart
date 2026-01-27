import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

/// Test scraping trực tiếp từ website nếu API không hoạt động
void main() async {
  print('═══════════════════════════════════════════════════════');
  print('🧪 TEST BACKUP: Scraping từ website BTMC và PNJ');
  print('═══════════════════════════════════════════════════════\n');

  // Test 1: Scrape từ website BTMC
  await scrapeBTMCWebsite();
  
  print('\n');
  
  // Test 2: Scrape từ website PNJ
  await scrapePNJWebsite();
  
  print('\n');
  
  // Test 3: Thử API BTMC khác
  await testAlternativeBTMC();
  
  print('\n═══════════════════════════════════════════════════════');
  print('✅ TEST HOÀN TẤT');
  print('═══════════════════════════════════════════════════════');
}

/// Scrape từ trang chủ BTMC
Future<void> scrapeBTMCWebsite() async {
  print('📋 TEST 1: Scrape website BTMC');
  print('─────────────────────────────────────────────────────');
  
  const url = 'https://baotinminhchau.vn/gia-vang';
  
  try {
    print('🔄 Đang truy cập: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml',
      },
    ).timeout(const Duration(seconds: 15));
    
    print('📡 Status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Website accessible!\n');
      
      final document = html_parser.parse(utf8.decode(response.bodyBytes));
      
      // Tìm bảng giá vàng
      final tables = document.querySelectorAll('table');
      print('📊 Tìm thấy ${tables.length} bảng trong trang\n');
      
      if (tables.isNotEmpty) {
        final table = tables.first;
        final rows = table.querySelectorAll('tr');
        
        print('💰 Dữ liệu giá vàng (${rows.length} hàng):\n');
        
        for (var i = 0; i < rows.length && i < 10; i++) {
          final row = rows[i];
          final cells = row.querySelectorAll('td, th');
          
          if (cells.length >= 3) {
            final name = cells[0].text.trim();
            final buy = cells[1].text.trim();
            final sell = cells[2].text.trim();
            
            if (name.isNotEmpty) {
              print('${i + 1}. $name');
              print('   Mua: $buy | Bán: $sell\n');
            }
          }
        }
      } else {
        print('⚠️ Không tìm thấy bảng giá');
        // Print một phần HTML để debug
        print('\n📄 HTML snippet:');
        print(response.body.substring(0, 500));
      }
    } else {
      print('❌ HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Lỗi: $e');
  }
}

/// Scrape từ trang chủ PNJ
Future<void> scrapePNJWebsite() async {
  print('📋 TEST 2: Scrape website PNJ');
  print('─────────────────────────────────────────────────────');
  
  const url = 'https://www.pnj.com.vn/blog/gia-vang/';
  
  try {
    print('🔄 Đang truy cập: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml',
      },
    ).timeout(const Duration(seconds: 15));
    
    print('📡 Status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Website accessible!\n');
      
      final document = html_parser.parse(utf8.decode(response.bodyBytes));
      
      // Tìm bảng giá vàng
      final tables = document.querySelectorAll('table');
      print('📊 Tìm thấy ${tables.length} bảng trong trang\n');
      
      if (tables.isNotEmpty) {
        for (var tableIndex = 0; tableIndex < tables.length && tableIndex < 2; tableIndex++) {
          final table = tables[tableIndex];
          final rows = table.querySelectorAll('tr');
          
          print('💰 Bảng ${tableIndex + 1} (${rows.length} hàng):\n');
          
          for (var i = 0; i < rows.length && i < 5; i++) {
            final row = rows[i];
            final cells = row.querySelectorAll('td, th');
            
            if (cells.length >= 2) {
              final text = cells.map((c) => c.text.trim()).join(' | ');
              print('   $text');
            }
          }
          print('');
        }
      } else {
        print('⚠️ Không tìm thấy bảng giá');
      }
    } else {
      print('❌ HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Lỗi: $e');
  }
}

/// Test BTMC API alternatives
Future<void> testAlternativeBTMC() async {
  print('📋 TEST 3: API BTMC thay thế');
  print('─────────────────────────────────────────────────────');
  
  final urls = [
    'http://api.btmc.vn/api/BTMCAPI/getpricebtmc',
    'http://giavang.baotinminhchau.com/api/getprice',
    'https://www.btmc.vn/api/gold-price',
  ];
  
  for (var url in urls) {
    try {
      print('🔄 Đang thử: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'application/json, application/xml, */*',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('   Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('   ✅ Thành công!');
        print('   Content-Type: ${response.headers['content-type']}');
        print('   Body preview: ${response.body.substring(0, 100)}...\n');
      } else {
        print('   ❌ Failed\n');
      }
    } catch (e) {
      print('   ❌ Error: ${e.toString().substring(0, 50)}...\n');
    }
  }
}
