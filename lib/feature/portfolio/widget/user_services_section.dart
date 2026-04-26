import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserServicesSection extends StatelessWidget {
  final List<ServiceModel> services;
  const UserServicesSection({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان بالخط بتاعنا ولون الهوية
        Text(
          "الخدمات المتاحة",
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            color: const Color(0xFF2F3E34),
          ),
        ),
        const SizedBox(height: 15),

        // استخدمنا ListView عرضي أسرع وأخف في الأداء
        SizedBox(
          height: 65.h, // ارتفاع محكوم عشان ميبقاش ضخم
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _serviceCard(services[index].title);
            },
          ),
        ),
      ],
    );
  }

  Widget _serviceCard(String title) {
    return Container(
      width: 170.w,
      margin: EdgeInsets.only(left: 12.w), // مسافة للشمال في الـ RTL
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFF2F3E34).withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F3E34).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة باللون البني المحروق بتاع الهوية
          const Icon(
            Icons.palette_outlined,
            color: Color(0xFF9C5A1A),
            size: 18,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'ElMessiri',
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: const Color(0xFF2F3E34),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
