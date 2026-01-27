import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/features/app/presentation/screens/record_transaction_screen.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/fake_data/fake_portfolio_data.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/constants/app_colors.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);
    final items = FakePortfolioData.getItemsByType(_selectedType);
    final summary = FakePortfolioData.getSummary();
    final nf = NumberFormat('#,##0', 'vi_VN');

    return Column(
      children: [
        AppHeader(
          title: 'Portfolio',
          subtitle: '${items.length} assets',
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
          bottom: _TypeFilter(
            types: FakePortfolioData.types,
            selected: _selectedType,
            onChanged: (type) => setState(() => _selectedType = type),
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
                // Summary Card
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryItem(
                              label: 'Total Value',
                              value: '${nf.format(summary['totalValue'])} VND',
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _SummaryItem(
                              label: 'Total Profit',
                              value: '${nf.format(summary['totalProfit'])} VND',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RecordTransactionScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('New Transaction'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Portfolio Items
                ...items.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _PortfolioItemCard(item: item),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeFilter extends StatelessWidget {
  final List<String> types;
  final String selected;
  final ValueChanged<String> onChanged;

  const _TypeFilter({
    required this.types,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = type == selected;
          return GestureDetector(
            onTap: () => onChanged(type),
            child: Container(
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  FakePortfolioData.getTypeName(type),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _PortfolioItemCard extends StatelessWidget {
  final FakePortfolioItem item;

  const _PortfolioItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'vi_VN');
    final profitColor = item.profit >= 0 ? Colors.green : Colors.red;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getTypeColor(item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  FakePortfolioData.getTypeName(item.type),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: _getTypeColor(item.type),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Quantity: ${item.quantity} ${item.unit}',
                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
              ),
              const Spacer(),
              Text(
                'Buy: ${nf.format(item.buyPrice)}',
                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: profitColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Value', style: TextStyle(fontSize: 9.sp, color: Colors.black54)),
                    Text(
                      '${nf.format(item.totalCurrentValue)} VND',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Profit', style: TextStyle(fontSize: 9.sp, color: Colors.black54)),
                    Text(
                      '${item.profit >= 0 ? '+' : ''}${nf.format(item.profit)} (${item.profitPercent.toStringAsFixed(2)}%)',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: profitColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item.note != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Note: ${item.note}',
              style: TextStyle(fontSize: 9.sp, color: Colors.black45, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'currency':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
