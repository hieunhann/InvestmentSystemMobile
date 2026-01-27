import 'dart:convert';
import 'package:http/http.dart' as http;

/// Debug BTMC API JSON structure
void main() async {
  print('🔍 DEBUG BTMC API JSON Structure\n');
  
  const btmcUrl = 'http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v';
  
  try {
    final response = await http.get(Uri.parse(btmcUrl)).timeout(const Duration(seconds: 15));
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      
      print('📦 Full JSON Structure:');
      print('─────────────────────────────────────────\n');
      
      // Pretty print với indent
      final prettyJson = JsonEncoder.withIndent('  ').convert(jsonData);
      
      // Print first 2000 characters
      print(prettyJson.substring(0, 2000));
      print('\n... (truncated)\n');
      
      // Analyze structure
      print('📊 Analysis:');
      print('─────────────────────────────────────────');
      
      if (jsonData is Map && jsonData.containsKey('DataList')) {
        final dataList = jsonData['DataList'];
        print('✓ DataList exists (type: ${dataList.runtimeType})');
        
        if (dataList is Map) {
          print('✓ DataList keys: ${dataList.keys.toList()}');
          
          if (dataList.containsKey('Data')) {
            final data = dataList['Data'];
            print('✓ Data exists (type: ${data.runtimeType})');
            
            if (data is List && data.isNotEmpty) {
              print('✓ Data length: ${data.length}');
              print('\n📋 First item structure:');
              print('─────────────────────────────────────────');
              final firstItem = data[0];
              print('Type: ${firstItem.runtimeType}');
              if (firstItem is Map) {
                print('Keys: ${firstItem.keys.toList()}');
                print('\nFull first item:');
                print(JsonEncoder.withIndent('  ').convert(firstItem));
              }
              
              // Find an item with actual price data
              print('\n🔍 Looking for items with price data...');
              for (var i = 0; i < data.length && i < 20; i++) {
                final item = data[i];
                if (item is Map) {
                  final buy = item['@buy'] ?? item['buy'] ?? '';
                  final sell = item['@sell'] ?? item['sell'] ?? '';
                  
                  if (buy != '' && buy != '0' && sell != '' && sell != '0') {
                    print('\n✅ Item $i has price data:');
                    print(JsonEncoder.withIndent('  ').convert(item));
                    break;
                  }
                }
              }
            }
          }
        }
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
