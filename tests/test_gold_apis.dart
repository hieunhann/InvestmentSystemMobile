import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

/// Script test để gọi thử BTMC và PNJ API
void main() async {
  print('═══════════════════════════════════════════════════════');
  print('🧪 TEST: BTMC & PNJ Gold Price APIs');
  print('═══════════════════════════════════════════════════════\n');

  // Test 1: BTMC API
  await testBTMCApi();
  
  print('\n');
  
  // Test 2: PNJ API
  await testPNJApi();
  
  print('\n═══════════════════════════════════════════════════════');
  print('✅ TEST HOÀN TẤT');
  print('═══════════════════════════════════════════════════════');
}

/// Test BTMC API
Future<void> testBTMCApi() async {
  print('📋 TEST 1: BTMC API (Bảo Tín Mạnh Hải)');
  print('─────────────────────────────────────────────────────');
  
  const btmcUrl = 'http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v';
  
  try {
    print('🔄 Đang gọi: $btmcUrl');
    
    final response = await http.get(
      Uri.parse(btmcUrl),
      headers: {
        'Accept': 'application/json, application/xml, text/xml, */*',
        'User-Agent': 'Mozilla/5.0',
      },
    ).timeout(const Duration(seconds: 15));
    
    print('📡 Status code: ${response.statusCode}');
    print('📦 Content-Type: ${response.headers['content-type']}');
    print('📏 Content length: ${response.bodyBytes.length} bytes');
    
    if (response.statusCode == 200) {
      print('✅ Response thành công!\n');
      
      // Thử parse JSON
      try {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('📦 Format: JSON');
        print('📦 Type: ${jsonData.runtimeType}');
        
        if (jsonData is Map && jsonData.containsKey('DataList')) {
          final dataList = jsonData['DataList'];
          print('📦 DataList found!\n');
          
          if (dataList is Map && dataList.containsKey('Data')) {
            final data = dataList['Data'] as List;
            print('💰 Tìm thấy ${data.length} loại vàng:\n');
            
            // Hiển thị 5 loại vàng đầu tiên
            for (var i = 0; i < data.length && i < 5; i++) {
              final item = data[i];
              final name = item['@n_1'] ?? item['name'] ?? 'Unknown';
              final buy = item['@buy'] ?? item['buy'] ?? '0';
              final sell = item['@sell'] ?? item['sell'] ?? '0';
              
              print('${i + 1}. $name');
              print('   💵 Mua vào: $buy');
              print('   💵 Bán ra: $sell\n');
            }
            
            if (data.length > 5) {
              print('   ... và ${data.length - 5} loại vàng khác');
            }
          }
        }
      } catch (jsonError) {
        print('⚠️ Không phải JSON, thử parse XML...');
        
        // Thử parse XML
        try {
          final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
          print('📦 Format: XML\n');
          
          final dataList = document.findAllElements('DataList').firstOrNull;
          if (dataList != null) {
            final city = dataList.getAttribute('city') ?? '';
            final date = dataList.getAttribute('date') ?? '';
            final time = dataList.getAttribute('time') ?? '';
            
            print('📍 Thành phố: $city');
            print('📅 Ngày: $date');
            print('⏰ Giờ: $time\n');
            
            final dataHolders = dataList.findElements('DataHolder').toList();
            print('💰 Tìm thấy ${dataHolders.length} loại vàng:\n');
            
            for (var i = 0; i < dataHolders.length && i < 5; i++) {
              final holder = dataHolders[i];
              final type = holder.getAttribute('row') ?? '';
              final buy = holder.getAttribute('buy') ?? '0';
              final sell = holder.getAttribute('sell') ?? '0';
              
              print('${i + 1}. $type');
              print('   💵 Mua vào: $buy triệu/lượng');
              print('   💵 Bán ra: $sell triệu/lượng\n');
            }
          }
        } catch (xmlError) {
          print('❌ Không parse được cả JSON và XML: $xmlError');
          print('📄 Raw data preview:');
          print(response.body.substring(0, 500));
        }
      }
    } else {
      print('❌ HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('❌ Lỗi: $e');
  }
}

/// Test PNJ API
Future<void> testPNJApi() async {
  print('📋 TEST 2: PNJ API (Phú Nhuận Jewelry)');
  print('─────────────────────────────────────────────────────');
  
  const pnjUrl = 'https://api.pnj.io/pnjcomvn/v1/gold-price';
  
  try {
    print('🔄 Đang gọi: $pnjUrl');
    
    final response = await http.get(
      Uri.parse(pnjUrl),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0',
      },
    ).timeout(const Duration(seconds: 15));
    
    print('📡 Status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Response thành công!\n');
      
      // Parse JSON
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      
      print('📦 Cấu trúc JSON:');
      print('   Type: ${jsonData.runtimeType}');
      print('   Keys: ${jsonData is Map ? jsonData.keys.toList() : "N/A"}\n');
      
      // Xử lý các format JSON khác nhau
      List<dynamic> goldPrices = [];
      
      if (jsonData is List) {
        goldPrices = jsonData;
      } else if (jsonData is Map) {
        if (jsonData.containsKey('data')) {
          goldPrices = jsonData['data'] as List? ?? [];
        } else if (jsonData.containsKey('goldPrice')) {
          goldPrices = jsonData['goldPrice'] as List? ?? [];
        } else if (jsonData.containsKey('prices')) {
          goldPrices = jsonData['prices'] as List? ?? [];
        }
      }
      
      if (goldPrices.isNotEmpty) {
        print('💰 Tìm thấy ${goldPrices.length} loại vàng:\n');
        
        // Hiển thị 5 loại đầu tiên
        for (var i = 0; i < goldPrices.length && i < 5; i++) {
          final item = goldPrices[i];
          
          // Lấy thông tin với nhiều key khác nhau
          final name = item['name'] ?? 
                      item['productName'] ?? 
                      item['type'] ?? 
                      'Unknown';
          final buy = item['buy'] ?? 
                     item['buyPrice'] ?? 
                     item['giaMua'] ?? 
                     0;
          final sell = item['sell'] ?? 
                      item['sellPrice'] ?? 
                      item['giaBan'] ?? 
                      0;
          
          print('${i + 1}. $name');
          print('   💵 Mua vào: $buy');
          print('   💵 Bán ra: $sell\n');
        }
        
        if (goldPrices.length > 5) {
          print('   ... và ${goldPrices.length - 5} loại vàng khác');
        }
      } else {
        print('⚠️ Không tìm thấy dữ liệu giá vàng');
        print('📄 Raw JSON (first 500 chars):');
        print(json.encode(jsonData).substring(0, 500));
      }
    } else {
      print('❌ HTTP ${response.statusCode}: ${response.reasonPhrase}');
      print('Response body: ${response.body.substring(0, 200)}...');
    }
  } catch (e) {
    print('❌ Lỗi: $e');
  }
}
