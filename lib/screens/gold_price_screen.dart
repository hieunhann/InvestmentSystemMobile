import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/models/gold_price_vietnam.dart';
import 'package:my_flutter_app/models/gold_price_international.dart';
import 'package:my_flutter_app/models/exchange_rate.dart';
import 'package:my_flutter_app/services/gold_price_service.dart';
import 'package:my_flutter_app/widgets/loading_overlay.dart';

class GoldPriceScreen extends StatefulWidget {
  const GoldPriceScreen({super.key});

  @override
  State<GoldPriceScreen> createState() => _GoldPriceScreenState();
}

class _GoldPriceScreenState extends State<GoldPriceScreen> {
  final GoldPriceService _service = GoldPriceService();
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');
  
  BTMCApiResponse? _vietnamData;
  GoldPriceInternational? _internationalData;
  ExchangeRateResponse? _exchangeRates;
  double _usdToVnd = 24000;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _service.getAllData();
      
      setState(() {
        _vietnamData = results['vietnam'];
        _internationalData = results['international'];
        _exchangeRates = results['exchangeRates'];
        _usdToVnd = results['usdToVnd'] ?? 24000;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('So Sánh Giá Vàng & Bạc'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrices,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(_errorMessage!, style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadPrices,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_vietnamData == null && _internationalData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadPrices,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUpdateTime(),
            SizedBox(height: 16.h),
            _buildVietnamPrices(),
            SizedBox(height: 24.h),
            _buildInternationalPrices(),
            SizedBox(height: 24.h),
            _buildComparison(),
            SizedBox(height: 24.h),
            _buildExchangeRates(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateTime() {
    final now = DateFormat('HH:mm:ss - dd/MM/yyyy').format(DateTime.now());
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 20.w, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            'Cập nhật: $now',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVietnamPrices() {
    if (_vietnamData == null || _vietnamData!.prices.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🇻🇳 Giá Vàng Việt Nam',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'API BTMC đang bảo trì.\nVui lòng thử lại sau.',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🇻🇳 Giá Vàng Việt Nam (${_vietnamData!.city})',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        ..._vietnamData!.prices.map((price) => _buildPriceCard(
          title: price.type,
          buyPrice: '${_currencyFormat.format(price.buyPrice)} đ',
          sellPrice: '${_currencyFormat.format(price.sellPrice)} đ',
          isVietnam: true,
        )),
      ],
    );
  }

  Widget _buildInternationalPrices() {
    if (_internationalData == null) return const SizedBox.shrink();

    final goldVND = _internationalData!.goldPriceInVND(_usdToVnd);
    final silverVND = _internationalData!.silverPriceInVND(_usdToVnd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🌍 Giá Vàng & Bạc Quốc Tế',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildPriceCard(
          title: 'Vàng (Gold)',
          buyPrice: '\$${_internationalData!.goldPrice.toStringAsFixed(2)}/oz',
          sellPrice: '≈ ${_currencyFormat.format(goldVND)} đ/chỉ',
          isVietnam: false,
        ),
        SizedBox(height: 12.h),
        _buildPriceCard(
          title: 'Bạc (Silver)',
          buyPrice: '\$${_internationalData!.silverPrice.toStringAsFixed(2)}/oz',
          sellPrice: '≈ ${_currencyFormat.format(silverVND)} đ/chỉ',
          isVietnam: false,
        ),
      ],
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String buyPrice,
    required String sellPrice,
    required bool isVietnam,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVietnam ? 'Mua vào' : 'Giá USD',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    buyPrice,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isVietnam ? 'Bán ra' : 'Giá VNĐ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    sellPrice,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparison() {
    if (_vietnamData == null || _internationalData == null) {
      return const SizedBox.shrink();
    }

    // Kiểm tra xem có data không
    if (_vietnamData!.prices.isEmpty) {
      return const SizedBox.shrink();
    }

    // Lấy giá vàng SJC để so sánh
    GoldPriceVietnam? sjcGold;
    try {
      sjcGold = _vietnamData!.prices.firstWhere(
        (p) => p.type.contains('SJC'),
      );
    } catch (e) {
      // Nếu không tìm thấy SJC, lấy item đầu tiên
      sjcGold = _vietnamData!.prices.first;
    }

    final intGoldVND = _internationalData!.goldPriceInVND(_usdToVnd);
    final difference = sjcGold.sellPrice - intGoldVND;
    final percentDiff = (difference / intGoldVND * 100);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: AppColors.primary, size: 24.w),
              SizedBox(width: 8.w),
              Text(
                'So Sánh',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Chênh lệch giá vàng VN vs Quốc tế:',
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            '${_currencyFormat.format(difference.abs())} đ/chỉ',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: difference > 0 ? Colors.red : Colors.green,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '(${percentDiff > 0 ? '+' : ''}${percentDiff.toStringAsFixed(2)}%)',
            style: TextStyle(
              fontSize: 16.sp,
              color: difference > 0 ? Colors.red : Colors.green,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            difference > 0
                ? '💡 Vàng trong nước đang cao hơn giá quốc tế'
                : '💡 Vàng trong nước đang thấp hơn giá quốc tế',
            style: TextStyle(fontSize: 14.sp, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRates() {
    if (_exchangeRates == null || _exchangeRates!.rates.isEmpty) {
      return const SizedBox.shrink();
    }

    // Chỉ lấy USD
    final usdRate = _exchangeRates!.rates.firstWhere(
      (rate) => rate.currencyCode == 'USD',
      orElse: () => _exchangeRates!.rates.first,
    );

    if (usdRate.currencyCode != 'USD') {
      return const SizedBox.shrink();
    }

    // Tính chênh lệch mua - bán
    final buyValue = usdRate.buyValue;
    final sellValue = usdRate.sellValue;
    final spread = sellValue - buyValue;
    final spreadPercent = (spread / buyValue * 100);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💵', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8.w),
              Text(
                'Tỷ Giá Đô La Mỹ (USD)',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Nguồn: ${_exchangeRates!.source} • ${usdRate.currencyName}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Giá mua - bán
          Row(
            children: [
              Expanded(
                child: _buildUsdRateCard('Mua vào', usdRate.buy, Colors.green),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildUsdRateCard('Bán ra', usdRate.sell, Colors.red),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Giá chuyển khoản
          _buildUsdRateCard('Chuyển khoản', usdRate.transfer, Colors.blue),
          
          SizedBox(height: 16.h),
          
          // Chênh lệch
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Chênh lệch mua - bán',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currencyFormat.format(spread)} VNĐ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.orange[700],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${spreadPercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '💡 Ngân hàng kiếm ${_currencyFormat.format(spread)}đ cho mỗi \$1',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // So sánh với tỷ giá dùng cho vàng
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔄 Tỷ giá quy đổi giá vàng',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '1 USD = ${_currencyFormat.format(_usdToVnd)} VNĐ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '💡 Dùng giá bán (${usdRate.sell}) để tính giá vàng quốc tế sang VNĐ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsdRateCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'VNĐ',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateColumn(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
