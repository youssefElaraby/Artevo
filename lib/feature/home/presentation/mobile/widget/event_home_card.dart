import 'package:art_by_hager_ismail/core/route_manager/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'event_details_sheet.dart';

class EventHomeCard extends StatelessWidget {
  final dynamic event;

  const EventHomeCard({super.key, required this.event});

  // ميثود فتح اللوكيشن
  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching url: $e');
    }
  }

  void _handleBookingClick(BuildContext context) {
    _showBookingSheet(context);
  }

  void showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF8F4F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text(
          "تنبيه",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'ElMessiri',
            color: Color(0xFF2F3E34),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "يجب تسجيل الدخول أولاً لتتمكن من إتمام عملية الحجز.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF2F3E34)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F3E34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                PageRoutesName.signInRoute,
                arguments: {'redirectBack': true},
              );
            },
            child: const Text(
              "تسجيل الدخول",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsSheet(
        event: event,
        onUnauthenticated: () => showLoginAlert(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220.h,
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // 🖼️ استخدام CachedNetworkImage مع شيمر داخلي للصورة
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: event.eventImageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: const Color(0xFFD8C9B6)),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFE8DDCF),
                  child: const Icon(Icons.wifi_off_rounded, color: Colors.grey),
                ),
              ),
            ),
            // Layer الـ Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventTitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ElMessiri',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildActionChip(
                        icon: Icons.location_on,
                        label: event.eventLocationName ?? "الموقع",
                        onTap: () => _launchUrl(event.eventLocationUrl),
                      ),
                      const Spacer(),
                      _buildPrimaryBtn(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🦴 ميثود الشيمر للهيكل (تستخدمها في الهوم اسكرين وقت اللودنج)
  static Widget buildShimmer() {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Colors.white,
      colorOpacity: 0.4,
      child: Container(
        width: double.infinity,
        height: 220.h,
        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFD8C9B6),
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleBookingClick(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8DDCF),
        foregroundColor: const Color(0xFF2F3E34),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        "تفاصيل الحجز",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
          fontFamily: 'ElMessiri',
        ),
      ),
    );
  }
}
