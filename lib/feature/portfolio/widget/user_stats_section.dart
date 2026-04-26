import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserStatsSection extends StatelessWidget {
  final List<StatCardModel> stats;
  const UserStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // حددنا ارتفاع ثابت عشان الـ ListView يعرف يرسم نفسه
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return _statCard(stats[index].value, stats[index].title);
        },
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      // عرض ثابت للكارت عشان الكلام ميتضغطش
      width: 110.w,
      margin: EdgeInsets.only(left: 10.w), // مسافة بين الكروت
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E34).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF2F3E34).withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: const Color(0xFF9C5A1A),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1, // سطر واحد عشان التنسيق
            overflow: TextOverflow.ellipsis, // لو الكلام طويل يحط نقط
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF2F3E34),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
