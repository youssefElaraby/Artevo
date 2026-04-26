import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../booking/model/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityBookings extends StatefulWidget {
  final List<BookingModel> bookings;

  const ActivityBookings({super.key, required this.bookings});

  @override
  State<ActivityBookings> createState() => _ActivityBookingsState();
}

class _ActivityBookingsState extends State<ActivityBookings> {
  // قائمة لتخزين الـ IDs التي تم فتحها (لقراءة الحالة "جديد")
  Set<String> _openedBookingIds = {};

  @override
  void initState() {
    super.initState();
    _loadOpenedStatus();
  }

  // تحميل الداتا من الجهاز
  Future<void> _loadOpenedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _openedBookingIds = (prefs.getStringList('opened_bookings') ?? [])
          .toSet();
    });
  }

  // حفظ إن الحجز ده اتفتح خلاص
  Future<void> _markAsOpened(String id) async {
    if (!_openedBookingIds.contains(id)) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _openedBookingIds.add(id);
      });
      await prefs.setStringList('opened_bookings', _openedBookingIds.toList());
    }
  }

  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return {
          "color": const Color(0xFF2F3E34),
          "label": "تم القبول",
          "icon": Icons.check_circle_rounded,
        };
      case "rejected":
        return {
          "color": const Color(0xFFD63031),
          "label": "تعذر القبول",
          "icon": Icons.cancel_rounded,
        };
      case "completed":
        return {
          "color": const Color(0xFF2F3E34),
          "label": "جلسة مكتملة",
          "icon": Icons.stars_rounded,
        };
      case "pending":
      default:
        return {
          "color": const Color(0xFF9C5A1A),
          "label": "قيد المراجعة",
          "icon": Icons.watch_later_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookings.isEmpty) return _buildEmptyState();

    final sortedBookings = widget.bookings.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      itemCount: sortedBookings.length,
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (context, index) {
        final booking = sortedBookings[index];
        final statusDetails = _getStatusDetails(booking.status);
        final Color statusColor = statusDetails["color"];

        // هل الحجز ده "جديد" (لم يفتح من قبل)؟
        final bool isNew = !_openedBookingIds.contains(booking.id);

        final sessionDate = DateFormat(
          'EEEE, dd MMM',
          'ar',
        ).format(booking.date);
        final requestTime = DateFormat(
          'hh:mm a | yyyy/MM/dd',
          'ar',
        ).format(booking.createdAt);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isNew ? statusColor.withOpacity(0.5) : Colors.transparent,
              width: isNew ? 1.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: isNew
                    ? statusColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isNew ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              onExpansionChanged: (opened) {
                if (opened) _markAsOpened(booking.id);
              },
              tilePadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      statusDetails["icon"],
                      color: statusColor,
                      size: 22.sp,
                    ),
                  ),
                  if (isNew) // نقطة "تنبيه" لو الحجز جديد
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                booking.name,
                style: TextStyle(
                  fontWeight: isNew ? FontWeight.w900 : FontWeight.bold,
                  fontSize: 15.sp,
                  fontFamily: 'Tajawal',
                  color: const Color(0xFF2F3E34),
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  "${booking.placeName ?? 'جلسة خاصة'} • ${booking.time}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isNew ? statusColor : Colors.grey[600],
                    fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isNew)
                    Text(
                      "جديد",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF9C5A1A),
                    size: 24.sp,
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 15.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFFE8DDCF),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      _buildDetailRow(
                        Icons.calendar_month,
                        "تاريخ الجلسة",
                        sessionDate,
                      ),
                      _buildDetailRow(
                        Icons.payments_outlined,
                        "التكلفة",
                        "${booking.price?.toInt() ?? 0} ج.م",
                      ),
                      _buildDetailRow(
                        Icons.phone_android,
                        "الهاتف",
                        booking.phone,
                      ),
                      _buildDetailRow(
                        Icons.history_toggle_off_rounded,
                        "وقت الطلب",
                        requestTime,
                      ),

                      if (booking.notes != null && booking.notes!.isNotEmpty)
                        _buildDetailRow(
                          Icons.edit_note,
                          "ملاحظاتك",
                          booking.notes!,
                        ),

                      if (booking.status.toLowerCase() == "rejected" &&
                          booking.cancellationReason != null)
                        _buildRejectedBox(booking.cancellationReason!),

                      SizedBox(height: 15.h),
                      Text(
                        "ID: ${booking.id.split('_').last}",
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 9.sp,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 14.sp, color: const Color(0xFF9C5A1A)),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 10.sp),
              ),
              Text(
                value,
                style: TextStyle(
                  color: const Color(0xFF2F3E34),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedBox(String reason) {
    return Container(
      margin: EdgeInsets.only(top: 15.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFD63031).withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFFD63031).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFD63031),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "سبب الرفض: $reason",
              style: TextStyle(
                color: const Color(0xFFD63031),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.art_track_rounded,
            size: 70.sp,
            color: const Color(0xFFD8C9B6),
          ),
          SizedBox(height: 20.h),
          Text(
            "سجل حجوزاتك فارغ",
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3E34),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "ابدأ رحلتك الفنية واحجز مكانك الآن",
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
}
