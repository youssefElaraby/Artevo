import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingNotesField extends StatelessWidget {
  final TextEditingController controller;
  const BookingNotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: 'ملاحظات إضافية (اختياري)',
        hintText: 'أي تفاصيل تحب إضافتها للمرسم...',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 11.sp),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: const Color(0xFF2F3E34).withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Color(0xFF9C5A1A)),
        ),
      ),
    );
  }
}
