import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../resources/color_manager.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget? prefixIcon; // أيقونة تظهر قبل النص
  final Widget? suffixIcon; // أيقونة تظهر بعد النص
  final String label; // النص الافتراضي للزر
  final Color? backGroundColor; // لون الخلفية
  final double? radius; // درجة تقوس الحواف
  final void Function() onTap; // وظيفة الضغط
  final TextStyle? textStyle; // تصميم النص
  final bool isStadiumBorder; // إذا كانت الحواف مستديرة
  final Widget? child; // لو عايز تحط أي حاجة بدل النص، زي CircularProgressIndicator

  const CustomElevatedButton({
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.backGroundColor,
    this.isStadiumBorder = true,
    this.radius,
    this.textStyle,
    required this.label,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backGroundColor ?? AppColors.primaryColor,
        shape: isStadiumBorder
            ? const StadiumBorder()
            : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 17.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
      ),
      child: child ??
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) prefixIcon!,
              if (prefixIcon != null) SizedBox(width: 8.w),
              Text(
                label,
                style: textStyle,
              ),
              if (suffixIcon != null) ...[
                SizedBox(width: 8.w),
                suffixIcon!,
              ],
            ],
          ),
    );
  }
}
