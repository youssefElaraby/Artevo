import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserSkillsSection extends StatelessWidget {
  final List<SkillModel> skills;
  const UserSkillsSection({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "المهارات",
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            color: const Color(0xFF2F3E34),
          ),
        ),
        SizedBox(height: 15.h),
        // عرض المهارات واحدة تحت التانية
        ...skills.map((s) => _skill(s.name, s.percentage / 100)).toList(),
      ],
    );
  }

  Widget _skill(String title, double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'ElMessiri',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: const Color(0xFF2F3E34),
                ),
              ),
              Text(
                "${(value * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF9C5A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xFFD8C9B6), // لون قمح غامق (الخلفية)
            color: const Color(0xFF2F3E34), // اللون الزيتي (الهوية)
          ),
        ],
      ),
    );
  }
}
