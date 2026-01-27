import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/widgets/custom_button.dart';
import 'package:my_flutter_app/widgets/custom_text_field.dart';
import 'package:my_flutter_app/fake_data/fake_transaction_data.dart';
import 'package:intl/intl.dart';

class RecordTransactionScreen extends StatefulWidget {
  const RecordTransactionScreen({super.key});

  @override
  State<RecordTransactionScreen> createState() => _RecordTransactionScreenState();
}

class _RecordTransactionScreenState extends State<RecordTransactionScreen> {
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final topPad = (size.height * 0.02).clamp(12.0, 18.0);
    final bottomPad = (size.height * 0.02).clamp(12.0, 18.0);
    
    final transactions = _filterType == 'all'
        ? FakeTransactionData.transactions
        : FakeTransactionData.getTransactionsByType(_filterType);
    final nf = NumberFormat('#,##0', 'vi_VN');

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(horizontal, topPad, horizontal, bottomPad),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back, size: 20.w, color: Colors.white),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${transactions.length} transactions',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9.sp, color: Colors.white.withOpacity(0.9), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30.w),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(horizontal),
                children: [
                  SizedBox(height: 12.h),
                  // Filter tabs
                  SizedBox(
                    height: 36.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: FakeTransactionData.transactionTypes.length,
                      itemBuilder: (context, index) {
                        final type = FakeTransactionData.transactionTypes[index];
                        final isSelected = type == _filterType;
                        return GestureDetector(
                          onTap: () => setState(() => _filterType = type),
                          child: Container(
                            margin: EdgeInsets.only(right: 10.w),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Center(
                              child: Text(
                                FakeTransactionData.getTransactionTypeName(type),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Transactions list
                  ...transactions.map((txn) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: txn.isBuy ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  txn.isBuy ? 'BUY' : 'SELL',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: txn.isBuy ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                txn.id,
                                style: TextStyle(fontSize: 9.sp, color: Colors.black45),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('dd/MM/yyyy').format(txn.transactionDate),
                                style: TextStyle(fontSize: 9.sp, color: Colors.black45),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            txn.assetName,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Text(
                                'Quantity: ${txn.quantity} ${txn.unit}',
                                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
                              ),
                              const Spacer(),
                              Text(
                                'Price: ${nf.format(txn.price)}',
                                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Value', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
                                Text(
                                  '${nf.format(txn.totalValue)} VND',
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          if (txn.seller != null) ...[
                            SizedBox(height: 6.h),
                            Text(
                              'Seller: ${txn.seller}',
                              style: TextStyle(fontSize: 9.sp, color: Colors.black45),
                            ),
                          ],
                          if (txn.note != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Note: ${txn.note}',
                              style: TextStyle(fontSize: 9.sp, color: Colors.black45, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

