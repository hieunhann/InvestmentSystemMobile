import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialIconRow extends StatelessWidget {
  const SocialIconRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12.w,
      runSpacing: 8.h,
      children: const [
        _SocialIconButton(label: 'G'),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String label;

  const _SocialIconButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {},
      radius: 22.r,
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

