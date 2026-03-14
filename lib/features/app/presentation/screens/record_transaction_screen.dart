import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/app/bloc/portfolio_cubit.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';

class RecordTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const RecordTransactionScreen({super.key, this.initialData});

  @override
  State<RecordTransactionScreen> createState() => _RecordTransactionScreenState();
}
class _RecordTransactionScreenState extends State<RecordTransactionScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _assetType = 'Gold';
  String _unitSymbol = 'Luong';
  String _currencyCode = 'VND';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      final rawAsset = (data['assetName'] ?? 'Gold').toString().toLowerCase();
      _assetType = rawAsset.contains('silver') ? 'Silver' : 'Gold';
      _quantityController.text = (data['quantity'] as num?)?.toString() ?? '';
      _priceController.text = (data['entryPrice'] as num?)?.toString() ?? '';
      
      _unitSymbol = _mapApiUnitToDisplay(data['unitSymbol'] as String?);

      final rawCurrency = (data['currencyCode'] as String?)?.toUpperCase();
      _currencyCode = rawCurrency == 'USD' ? 'USD' : 'VND';
    } else {
      // Default initialization for new transactions
      _assetType = 'Gold';
      _unitSymbol = 'Luong';
      _currencyCode = 'VND';
    }
  }

  String _assetLabel() {
    return _assetType == 'Gold' ? 'SJC Gold' : 'Phu Quy Silver';
  }

  String _mapApiUnitToDisplay(String? raw) {
    final unit = (raw ?? '').toLowerCase();
    if (unit == 'chỉ' || unit == 'chi') return 'Chi';
    if (unit == 'kg' || unit == 'kilogram') return 'Kg';
    return 'Luong';
  }

  String _mapDisplayUnitToApi(String display) {
    switch (display) {
      case 'Chi':
        return 'Chỉ';
      case 'Kg':
        return 'Kilogram';
      case 'Luong':
      default:
        return 'Lượng';
    }
  }

  String _currencySymbol() {
    return _currencyCode == 'USD' ? '\$' : 'VND';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: Text(widget.initialData == null ? 'Record Transaction' : 'Edit Asset', 
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(horizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fill in the details for your precious metal transaction.',
              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
            ),
            SizedBox(height: 20.h),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text('Asset Information', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const Divider(),
                  SizedBox(height: 8.h),
                  _buildDropdown(
                    label: 'Metal Type',
                    value: _assetType,
                    items: ['Gold', 'Silver'],
                    onChanged: (val) {
                      setState(() {
                        _assetType = val!;
                        _unitSymbol = 'Luong';
                        _currencyCode = 'VND';
                      });
                    },
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Standard Product: ${_assetLabel()}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                  ),
                  SizedBox(height: 16.h),
                   Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Quantity',
                          hint: '0.00',
                          controller: _quantityController,
                          suffix: _unitSymbol,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Unit',
                          value: _unitSymbol,
                          items: ['Chi', 'Luong', 'Kg'],
                          onChanged: (val) => setState(() => _unitSymbol = val!),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pricing Details', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const Divider(),
                  SizedBox(height: 8.h),
                  Text(
                    'This asset will be saved in ${_currencyCode == 'USD' ? 'USD' : 'VND'}.',
                    style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          label: 'Receipt Price (${_currencyCode})',
                          hint: _currencyCode == 'USD' ? '0.00 USD' : '0 VND',
                          controller: _priceController,
                          suffix: _currencySymbol(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Currency',
                          value: _currencyCode,
                          items: ['VND', 'USD'],
                          onChanged: (val) => setState(() => _currencyCode = val!),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Saving as: ${_assetLabel()} • ${_unitSymbol} • ${_currencyCode}',
                      style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryVariant,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Save Transaction', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (widget.initialData != null) ...[
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Delete Transaction', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User session is invalid. Please login again.'), backgroundColor: Colors.red),
      );
      return;
    }

    final qty = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid quantity and price')));
      return;
    }

    setState(() => _isSaving = true);
    
    // Store PortfolioCubit before asynchronous gap
    final portfolioCubit = context.read<PortfolioCubit>();
    try {
      bool success;
      if (widget.initialData == null) {
        success = await portfolioCubit.addAsset(
              userId: userId,
              assetName: _assetType == 'Gold' ? 'Gold' : 'Silver',
              quantity: qty,
              unitSymbol: _mapDisplayUnitToApi(_unitSymbol),
              entryPrice: price,
              currencyCode: _currencyCode,
            );
      } else {
        success = await portfolioCubit.updateAsset(
              userId: userId,
              assetName: _assetType == 'Gold' ? 'Gold' : 'Silver',
              quantity: qty,
              unitSymbol: _mapDisplayUnitToApi(_unitSymbol),
              entryPrice: price,
              currencyCode: _currencyCode,
            );
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction recorded successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please check your data.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _delete() async {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User session is invalid. Please login again.'), backgroundColor: Colors.red),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this asset?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    final portfolioCubit = context.read<PortfolioCubit>();
    try {
      final success = await portfolioCubit.deleteAsset(
        userId: userId,
        assetName: _assetType == 'Gold' ? 'Gold' : 'Silver',
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset deleted successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete asset.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
