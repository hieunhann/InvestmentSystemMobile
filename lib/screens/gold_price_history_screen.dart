import 'package:flutter/material.dart';
import 'package:my_flutter_app/services/supabase_service.dart';
import 'package:my_flutter_app/models/supabase_market_price.dart';
import 'package:intl/intl.dart';

/// Screen lịch sử giá vàng - So sánh theo thời gian
/// Giải quyết feedback: "Biểu đồ cần thêm mốc thời gian"
class GoldPriceHistoryScreen extends StatefulWidget {
  final int regionId;
  final String regionName;

  const GoldPriceHistoryScreen({
    Key? key,
    required this.regionId,
    required this.regionName,
  }) : super(key: key);

  @override
  State<GoldPriceHistoryScreen> createState() => _GoldPriceHistoryScreenState();
}

class _GoldPriceHistoryScreenState extends State<GoldPriceHistoryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  // Time range options
  String _selectedRange = '7days'; // 7days, 1month, 3months
  List<SupabaseMarketPrice> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DateTime startDate;
      switch (_selectedRange) {
        case '7days':
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '1month':
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case '3months':
          startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        default:
          startDate = DateTime.now().subtract(const Duration(days: 7));
      }

      _history = await _supabaseService.getGoldPriceHistory(
        regionId: widget.regionId,
        startDate: startDate,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải lịch sử: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử giá vàng ${widget.regionName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Time range selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Khoảng thời gian:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: '7days',
                        label: Text('7 ngày'),
                        icon: Icon(Icons.calendar_today, size: 16),
                      ),
                      ButtonSegment(
                        value: '1month',
                        label: Text('1 tháng'),
                        icon: Icon(Icons.calendar_month, size: 16),
                      ),
                      ButtonSegment(
                        value: '3months',
                        label: Text('3 tháng'),
                        icon: Icon(Icons.date_range, size: 16),
                      ),
                    ],
                    selected: {_selectedRange},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _selectedRange = selection.first;
                      });
                      _loadHistory();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Statistics summary
          if (_history.isNotEmpty) _buildStatsSummary(),

          const Divider(height: 1),

          // History list
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    if (_history.isEmpty) return const SizedBox.shrink();

    final latest = _history.first;
    final oldest = _history.last;
    
    final buyChange = latest.buyPrice - oldest.buyPrice;
    final buyChangePercent = (buyChange / oldest.buyPrice) * 100;
    
    final sellChange = latest.sellPrice - oldest.sellPrice;
    final sellChangePercent = (sellChange / oldest.sellPrice) * 100;
    
    final avgBuy = _history.map((h) => h.buyPrice).reduce((a, b) => a + b) / _history.length;
    final avgSell = _history.map((h) => h.sellPrice).reduce((a, b) => a + b) / _history.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Thống kê ${_getRangeLabel()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Giá mua TB',
                  value: '${(avgBuy / 1000000).toStringAsFixed(2)} tr',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: 'Giá bán TB',
                  value: '${(avgSell / 1000000).toStringAsFixed(2)} tr',
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Biến động mua',
                  value: '${buyChangePercent >= 0 ? '+' : ''}${buyChangePercent.toStringAsFixed(2)}%',
                  icon: buyChangePercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: buyChangePercent >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: 'Biến động bán',
                  value: '${sellChangePercent >= 0 ? '+' : ''}${sellChangePercent.toStringAsFixed(2)}%',
                  icon: sellChangePercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: sellChangePercent >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Chưa có dữ liệu lịch sử',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Hệ thống scraper cần chạy để thu thập dữ liệu',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final price = _history[index];
        final prevPrice = index < _history.length - 1 ? _history[index + 1] : null;
        
        final buyChange = prevPrice != null ? price.buyPrice - prevPrice.buyPrice : 0.0;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber.shade100,
              child: Text(
                DateFormat('dd').format(price.timestamp),
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(price.timestamp),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                if (buyChange != 0)
                  Icon(
                    buyChange > 0 ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: buyChange > 0 ? Colors.green : Colors.red,
                  ),
                if (buyChange != 0)
                  Text(
                    ' ${(buyChange / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(
                      fontSize: 11,
                      color: buyChange > 0 ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Mua: ${(price.buyPrice / 1000000).toStringAsFixed(2)} tr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Bán: ${(price.sellPrice / 1000000).toStringAsFixed(2)} tr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRangeLabel() {
    switch (_selectedRange) {
      case '7days':
        return '7 ngày qua';
      case '1month':
        return '1 tháng qua';
      case '3months':
        return '3 tháng qua';
      default:
        return '';
    }
  }
}
