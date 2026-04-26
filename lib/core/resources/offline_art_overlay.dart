import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfflineArtOverlay extends StatelessWidget {
  const OfflineArtOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8DDCF).withOpacity(0.95), // نفس لون براند المرسم
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // لوحة أو سكتش رصاص لـ هاجر (لو عندك صورة سكتش حطها هنا)
          Icon(
            Icons.format_paint_rounded,
            size: 100.r,
            color: const Color(0xFF2F3E34).withOpacity(0.2),
          ),
          SizedBox(height: 20.h),
          Text(
            "ألواننا لسه موجودة.. بس النت هرب!",
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3E34),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
            child: Text(
              "تقدر تتفرج على المعرض (الجالري) المحمل مسبقاً لحد ما نرجع نربط اللوحة بالواقع.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: 30.h),
          // زرار "حاول تاني" بشكل فني
          OutlinedButton(
            onPressed: () { /* تشيك تاني على النت */ },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2F3E34)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("تحديث الحالة", style: TextStyle(color: Color(0xFF2F3E34))),
          ),
        ],
      ),
    );
  }
}