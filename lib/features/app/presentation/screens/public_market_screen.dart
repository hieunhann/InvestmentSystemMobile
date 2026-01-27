import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/simple_line_chart.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_app/fake_data/fake_market_data.dart';

class PublicMarketScreen extends StatefulWidget {
  const PublicMarketScreen({super.key});

  @override
  State<PublicMarketScreen> createState() => _PublicMarketScreenState();
}

class _PublicMarketScreenState extends State<PublicMarketScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);

    final usdToVnd = FakeMarketData.usdToVnd;

    return Column(
      children: [
        AppHeader(
          title: 'Welcome,',
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
          bottom: _MarketTabs(
            currentIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
              children: [
                if (_tabIndex == 0) ...[
                  // Gold Tab
                  _DomesticCard(),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _WorldCard(metalType: 'gold'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _SpreadCard(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Trend: Domestic vs. World',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SimpleLineChart(
                          seriesA: FakeMarketData.getDomesticHistory(),
                          seriesB: FakeMarketData.getWorldHistory(),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendDot(color: AppColors.secondary, label: 'Domestic Price (SJC)'),
                            SizedBox(width: 16.w),
                            _LegendDot(color: const Color(0xFFB0BEC5), label: 'World Price'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SmallTab(label: 'Product', isActive: true),
                            _SmallTab(label: 'Buy', isActive: false),
                            _SmallTab(label: 'Sell', isActive: false),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        ...FakeMarketData.vietnamPrices.map((p) => _VietnamProductRow(price: p)),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                ] else if (_tabIndex == 1) ...[
                  // Silver Tab
                  SizedBox(height: 12.h),
                  _WorldCard(metalType: 'silver'),
                  SizedBox(height: 12.h),
                  AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Silver market data from international sources.',
                        style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                      ),
                    ),
                  ),
                ] else ...[
                  // Foreign Currency Tab
                  SizedBox(height: 12.h),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exchange Rate', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                        SizedBox(height: 8.h),
                        Text(
                          '1 USD = ${NumberFormat('#,##0.00').format(usdToVnd)} VND',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _CurrencyConverter(usdToVnd: usdToVnd),
                  SizedBox(height: 12.h),
                  AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Foreign currency exchange information.',
                        style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _MarketTabs({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderTab(label: 'Gold', isActive: currentIndex == 0, onTap: () => onChanged(0)),
        _HeaderTab(label: 'Silver', isActive: currentIndex == 1, onTap: () => onChanged(1)),
        _HeaderTab(label: 'Foreign Currency', isActive: currentIndex == 2, onTap: () => onChanged(2)),
        const Spacer(),
        _MoreDropdown(onSelected: (_) {}),
      ],
    );
  }
}

class _MoreDropdown extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _MoreDropdown({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'more', child: Text('More')),
      ],
      child: Row(
        children: [
          Text('More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.sp)),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }
}

class _HeaderTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _HeaderTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 14.w, top: 10.h),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white.withOpacity(isActive ? 1 : 0.8),
          ),
        ),
      ),
    );
  }
}

class _DomesticCard extends StatelessWidget {
  const _DomesticCard();

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Domestic Price', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12.sp, color: Colors.black87, fontWeight: FontWeight.w800),
              children: [
                TextSpan(
                  text: '${_formatVND(FakeMarketData.domesticSellPrice)} VND',
                ),
                TextSpan(
                  text: '  / Ounce',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.black45),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text('Buy:', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
              SizedBox(width: 6.w),
              Text(
                '${_formatVND(FakeMarketData.domesticBuyPrice)} VND',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text('Sell Price Today', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
              SizedBox(width: 6.w),
              Text(
                '↓ ${FakeMarketData.domesticPriceChange.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  final String metalType;

  const _WorldCard({this.metalType = 'gold'});

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final label = metalType == 'silver' ? 'Silver Price' : 'Gold Price';
    final usd = metalType == 'silver' ? FakeMarketData.worldSilverPrice : FakeMarketData.worldGoldPrice;
    final vnd = metalType == 'silver' ? FakeMarketData.worldSilverPriceInVND : FakeMarketData.worldGoldPriceInVND;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12.sp, color: Colors.black87, fontWeight: FontWeight.w800),
              children: [
                TextSpan(text: '${usd.toStringAsFixed(2)} USD'),
                TextSpan(
                  text: ' / Ounce',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.black45),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text('Approx:', style: TextStyle(fontSize: 10.sp, color: Colors.black45)),
              SizedBox(width: 4.w),
              Text(
                '${_formatVND(vnd)} VND',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text('Converted', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
              SizedBox(width: 4.w),
              Text(
                '↑ +${FakeMarketData.worldPriceChange.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpreadCard extends StatelessWidget {
  const _SpreadCard();

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final gap = FakeMarketData.spreadGap;
    final risk = FakeMarketData.spreadRisk;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPREAD GAP', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                SizedBox(height: 6.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(text: '${_formatVND(gap)} VND'),
                      TextSpan(
                        text: ' / Ounce',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Higher than average,\npotential risk',
                  style: TextStyle(fontSize: 9.sp, color: Colors.black45, height: 1.2),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    risk,
                    style: TextStyle(fontSize: 9.sp, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
      ],
    );
  }
}

class _SmallTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _SmallTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        color: isActive ? Colors.black87 : Colors.black45,
      ),
    );
  }
}

class _VietnamProductRow extends StatelessWidget {
  final FakeGoldPrice price;

  const _VietnamProductRow({required this.price});

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final buy = price.buyPrice;
    final sell = price.sellPrice;
    final spread = (sell - buy).abs();
    final spreadColor = spread <= 500000
        ? const Color(0xFF2E7D32)
        : (spread <= 1500000 ? AppColors.primaryVariant : const Color(0xFFE53935));

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.stars, size: 16.w, color: AppColors.primaryVariant),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(price.type, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 2.h),
                Text(price.location, style: TextStyle(fontSize: 9.sp, color: Colors.black45)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_formatVND(buy)} VND', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text('Spread', style: TextStyle(fontSize: 9.sp, color: Colors.black45)),
                  SizedBox(width: 6.w),
                  Text(
                    _formatVND(spread),
                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: spreadColor),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Text(
            '${_formatVND(sell)} VND',
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _SkeletonMarket extends StatelessWidget {
  const _SkeletonMarket();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(height: 140.h, child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
    );
  }
}

class _CurrencyConverter extends StatefulWidget {
  final double usdToVnd;

  const _CurrencyConverter({required this.usdToVnd});

  @override
  State<_CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<_CurrencyConverter> {
  final _controller = TextEditingController();
  bool _isVndToUsd = true; // true = VND → USD, false = USD → VND
  double _result = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    final rawText = _controller.text.replaceAll('.', '').replaceAll(',', '');
    final input = double.tryParse(rawText) ?? 0;
    if (widget.usdToVnd <= 0) {
      setState(() => _result = 0);
      return;
    }
    
    setState(() {
      if (_isVndToUsd) {
        // VND → USD (nhập bỏ 3 số 0, nhân 1000 để lấy giá trị thực)
        final actualVnd = input * 1000;
        _result = actualVnd / widget.usdToVnd;
      } else {
        // USD → VND
        _result = input * widget.usdToVnd;
      }
    });
  }

  void _swap() {
    setState(() {
      _isVndToUsd = !_isVndToUsd;
      _result = 0;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0.00', 'vi_VN');
    final fromCurrency = _isVndToUsd ? 'VND' : 'USD';
    final toCurrency = _isVndToUsd ? 'USD' : 'VND';
    final hintText = _isVndToUsd ? 'EX: 10.000 = 10 Millions VND' : 'EX: 1000';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Currency Converter', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
              IconButton(
                onPressed: _swap,
                icon: Icon(Icons.swap_horiz, color: AppColors.primary, size: 24.w),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text('From $fromCurrency${_isVndToUsd ? ' (Unit: thousand)' : ''}', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
          SizedBox(height: 6.h),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorInputFormatter(),
            ],
            onChanged: (_) => _convert(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 11.sp, color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            ),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To $toCurrency', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                SizedBox(height: 6.h),
                Text(
                  _result == 0 ? '--' : nf.format(_result),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Xóa tất cả dấu chấm cũ
    final rawText = newValue.text.replaceAll('.', '');
    
    // Thêm dấu chấm ngăn cách 3 số từ phải sang trái
    final buffer = StringBuffer();
    for (int i = 0; i < rawText.length; i++) {
      if (i > 0 && (rawText.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(rawText[i]);
    }
    
    final formattedText = buffer.toString();
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

