import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PortfolioHeader extends StatelessWidget {
  const PortfolioHeader({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: isMobile ? 60.h : 40.h,
        bottom: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "معرض الأعمال الفنية",
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE8DDCF), // لون القمح الهادي
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            height: 3,
            width: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFF9C5A1A),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "استعرض لوحات، ورش، كورسات وجلسات ابتكار بكل سهولة.",
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color.fromARGB(179, 247, 246, 246),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
