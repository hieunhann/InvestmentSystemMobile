import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/providers/market_data_provider.dart';
import 'package:my_flutter_app/screens/gold_price_history_screen.dart';
import 'package:intl/intl.dart';

/// Screen demo MarketDataProvider - Lấy giá vàng và tỷ giá từ Supabase
/// 
/// Ưu điểm so với call API trực tiếp:
/// ✅ Không bị rate limit (429 Too Many Requests)
/// ✅ Có dữ liệu lịch sử để so sánh giá
/// ✅ Data được scrape tự động vào Supabase
class SupabaseMarketDataScreen extends StatefulWidget {
  const SupabaseMarketDataScreen({Key? key}) : super(key: key);

  @override
  State<SupabaseMarketDataScreen> createState() => _SupabaseMarketDataScreenState();
}

class _SupabaseMarketDataScreenState extends State<SupabaseMarketDataScreen> {
  @override
  void initState() {
    super.initState();
    // Load tất cả market data khi screen mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MarketDataProvider>(context, listen: false);
      provider.loadAllMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketData = Provider.of<MarketDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thị trường - Supabase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => marketData.refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // INFO CARD
            _buildInfoCard(),
            const SizedBox(height: 16),

            // TỶ GIÁ NGOẠI TỆ
            _buildSectionHeader('💱 TỶ GIÁ NGOẠI TỆ', 'Từ Vietcombank', Icons.currency_exchange),
            const SizedBox(height: 8),
            _buildExchangeRatesSection(marketData),
            const SizedBox(height: 24),

            // GIÁ VÀNG VIỆT NAM
            _buildSectionHeader('🏆 GIÁ VÀNG SJC', 'Các khu vực VN', Icons.diamond),
            const SizedBox(height: 8),
            _buildVietnamGoldSection(marketData),
            const SizedBox(height: 24),

            // GIÁ VÀNG/BẠC QUỐC TẾ
            _buildSectionHeader('🌍 GIÁ QUỐC TẾ', 'Từ Kitco', Icons.public),
            const SizedBox(height: 8),
            _buildGlobalMetalsSection(marketData),
            
            const SizedBox(height: 16),
            _buildLastUpdateInfo(marketData),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_done, color: Colors.blue.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dữ liệu từ Supabase',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Không bị rate limit • Có lịch sử',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExchangeRatesSection(MarketDataProvider marketData) {
    if (marketData.isLoadingExchangeRates) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (marketData.exchangeRatesError != null) {
      return _buildErrorCard(marketData.exchangeRatesError!);
    }

    if (marketData.exchangeRates.isEmpty) {
      return _buildEmptyCard('Chưa có dữ liệu tỷ giá');
    }

    // Hiển thị top 10 currencies phổ biến
    final topCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SGD', 'THB'];
    final displayRates = marketData.exchangeRates
        .where((rate) => topCurrencies.contains(rate.currencyCode))
        .toList();

    return Column(
      children: displayRates.map((rate) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                rate.currencyCode.substring(0, 1),
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              rate.currencyCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              rate.currencyName,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (rate.buyPrice != null)
                  Text(
                    'Mua: ${rate.buyPriceFormatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (rate.sellPrice != null)
                  Text(
                    'Bán: ${rate.sellPriceFormatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVietnamGoldSection(MarketDataProvider marketData) {
    if (marketData.isLoadingVietnamGold) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (marketData.vietnamGoldError != null) {
      return _buildErrorCard(marketData.vietnamGoldError!);
    }

    if (marketData.vietnamGoldPrices.isEmpty) {
      return _buildEmptyCard('Chưa có dữ liệu giá vàng VN');
    }

    // Hiển thị giá vàng các khu vực
    return Column(
      children: marketData.vietnamGoldPrices.map((gold) {
        // FIXED: Calculate spread correctly (bán - mua)
        final spreadVND = gold.sellPrice - gold.buyPrice;
        final spreadPercent = (spreadVND / gold.buyPrice) * 100;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber.shade100,
              child: Icon(
                Icons.location_on,
                color: Colors.amber.shade700,
              ),
            ),
            // ADDED: Tap to view history
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoldPriceHistoryScreen(
                    regionId: gold.regionId,
                    regionName: gold.regionName,
                  ),
                ),
              );
            },
            title: Row(
              children: [
                Text(
                  gold.regionName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                // FIXED: Show spread gap properly
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: spreadPercent > 1 ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Chênh ${spreadPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: spreadPercent > 1 ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Text(
                  'Mua: ${gold.buyPriceFormatted}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Bán: ${gold.sellPriceFormatted}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGlobalMetalsSection(MarketDataProvider marketData) {
    if (marketData.isLoadingGlobalMetals) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (marketData.globalMetalsError != null) {
      return _buildErrorCard(marketData.globalMetalsError!);
    }

    final goldPrice = marketData.globalGoldPrice;
    final silverPrice = marketData.globalSilverPrice;

    if (goldPrice == null && silverPrice == null) {
      return _buildEmptyCard('Chưa có dữ liệu giá quốc tế');
    }

    return Column(
      children: [
        if (goldPrice != null)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.yellow.shade100,
                child: Icon(
                  Icons.diamond,
                  color: Colors.yellow.shade700,
                ),
              ),
              title: const Text(
                'Gold (XAU)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                goldPrice.unitName,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Buy: ${goldPrice.buyPriceFormatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Sell: ${goldPrice.sellPriceFormatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (silverPrice != null)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  Icons.diamond_outlined,
                  color: Colors.grey.shade700,
                ),
              ),
              title: const Text(
                'Silver (XAG)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                silverPrice.unitName,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Buy: ${silverPrice.buyPriceFormatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Sell: ${silverPrice.sellPriceFormatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdateInfo(MarketDataProvider marketData) {
    final hasData = marketData.exchangeRates.isNotEmpty ||
        marketData.vietnamGoldPrices.isNotEmpty ||
        marketData.globalGoldPrice != null ||
        marketData.globalSilverPrice != null;

    if (!hasData) return const SizedBox.shrink();

    DateTime? latestTime;
    if (marketData.exchangeRates.isNotEmpty) {
      latestTime = marketData.exchangeRates.first.timestamp;
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dữ liệu từ Supabase',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (latestTime != null)
                    Text(
                      'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(latestTime)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về Screen này'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎯 Mục đích:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Demo MarketDataProvider lấy data từ Supabase'),
              SizedBox(height: 12),
              Text(
                '✅ Ưu điểm:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Không bị rate limit (429)\n'
                  '• Có dữ liệu lịch sử để so sánh\n'
                  '• Data được scrape tự động'),
              SizedBox(height: 12),
              Text(
                '📊 Data sources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Vietcombank: Tỷ giá ngoại tệ\n'
                  '• CafeF: Giá vàng SJC VN\n'
                  '• Kitco: Giá vàng/bạc quốc tế'),
              SizedBox(height: 12),
              Text(
                '⚙️ Backend:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Python scrapers → Supabase PostgreSQL'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
