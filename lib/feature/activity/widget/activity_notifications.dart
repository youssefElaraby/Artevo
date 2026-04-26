import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../booking/model/booking_model.dart';

class ActivityNotifications extends StatelessWidget {
  final List<BookingModel> bookings;

  const ActivityNotifications({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    // 🔥 التعديل الجوهري: الترتيب بناءً على createdAt (الأحدث فوق)
    final sortedBookings = bookings.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final notifications = _mapBookingsToNotifications(sortedBookings);

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        final Color typeColor = _getTypeColor(notif['type']!);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            leading: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notif['type']!),
                color: typeColor,
                size: 22.sp,
              ),
            ),
            title: Text(
              notif['title']!,
              style: TextStyle(
                fontFamily: 'ElMessiri',
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: const Color(0xFF2F3E34),
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif['subtitle']!,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  if (notif['reason'] != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      "• ${notif['reason']}",
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11.sp,
                        color: const Color(0xFFD63031),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Container(
              width: 4.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'approved':
        return const Color(0xFF2F3E34);
      case 'rejected':
        return const Color(0xFFD63031);
      case 'pending':
        return const Color(0xFF9C5A1A);
      case 'completed':
        return const Color(0xFF2F3E34);
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.watch_later_rounded;
      case 'completed':
        return Icons.stars_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 70.sp,
            color: const Color(0xFFD8C9B6),
          ),
          SizedBox(height: 20.h),
          Text(
            "صندوق التنبيهات فارغ",
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3E34),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "لا توجد تحديثات جديدة بخصوص حجوزاتك حالياً",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String?>> _mapBookingsToNotifications(
    List<BookingModel> bookings,
  ) {
    final List<Map<String, String?>> notifications = [];
    for (final booking in bookings) {
      final place = booking.placeName ?? 'الجلسة الخاصة';
      switch (booking.status.toLowerCase()) {
        case "approved":
          notifications.add({
            'title': "تم تأكيد الحجز بنجاح",
            'subtitle':
                "تمت الموافقة على طلب انضمامك لـ $place. ننتظرك في الموعد!",
            'type': 'approved',
          });
          break;
        case "rejected":
          notifications.add({
            'title': "نأسف، تعذر قبول الحجز",
            'subtitle': "تم رفض طلب الحجز الخاص بك في $place.",
            'reason':
                booking.cancellationReason ??
                "للمزيد من التفاصيل يرجى التواصل معنا.",
            'type': 'rejected',
          });
          break;
        case "completed":
          notifications.add({
            'title': "انتهت الجلسة الفنية",
            'subtitle':
                "سعدنا بزيارتك لمرسم هاجر في $place. شاركنا رأيك في التجربة!",
            'type': 'completed',
          });
          break;
        case "pending":
          notifications.add({
            'title': "طلبك قيد المراجعة حالياً",
            'subtitle':
                "تلقينا طلب حجزك في $place، وسيتم الرد عليك في أقرب وقت.",
            'type': 'pending',
          });
          break;
      }
    }
    return notifications;
  }
}
