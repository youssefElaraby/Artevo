import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../booking/model/booking_model.dart';

class ActivityFeedback extends StatelessWidget {
  final List<BookingModel> bookings;

  const ActivityFeedback({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    // 1. فلترة الحجوزات اللي فيها فيدباك (رأي هاجر)
    // 2. 🔥 الترتيب تنازلياً (الأحدث فوق) بناءً على تاريخ إنشاء الطلب createdAt
    final feedbacks =
        bookings
            .where((b) => b.feedback != null && b.feedback!.isNotEmpty)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (feedbacks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      itemCount: feedbacks.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final fb = feedbacks[index];
        final sessionName = fb.placeName ?? "جلسة خاصة";
        final rating = fb.rating?.toInt() ?? 0;

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F3E34).withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة دائرية فنية (أول حرف من اسم المكان)
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DDCF).withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        sessionName.isNotEmpty
                            ? sessionName[0].toUpperCase()
                            : 'S',
                        style: TextStyle(
                          fontFamily: 'ElMessiri',
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2F3E34),
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sessionName,
                          style: TextStyle(
                            fontFamily: 'ElMessiri',
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: const Color(0xFF2F3E34),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // نجوم التقييم بناءً على rating الحقيقي
                        Row(
                          children: List.generate(
                            5,
                            (star) => Icon(
                              star < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFF9C5A1A),
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (fb.feedback != null && fb.feedback!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf9f9f9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.black.withOpacity(0.03)),
                  ),
                  child: Text(
                    fb.feedback!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6F624C),
                      height: 1.5,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(25.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 60.sp,
              color: const Color(0xFFD8C9B6),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "لا يوجد آراء حالياً",
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3E34),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "آراء العملاء تظهر هنا بعد إتمام الجلسات الفنية",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
