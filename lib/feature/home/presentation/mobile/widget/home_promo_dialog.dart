import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePromoDialog extends StatelessWidget {
  final String imageUrl;
  final String title;

  const HomePromoDialog({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // عشان الزوايا تبان مقصوصة صح
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          // الكارت الأساسي
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8DDCF),
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🛠️ استخدام CachedNetworkImage بدلاً من Image.network
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25.r),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 350.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // 🔄 الشيمر أثناء التحميل (باستخدام مكتبتك)
                    placeholder: (context, url) => Shimmer(
                      duration: const Duration(seconds: 2),
                      color: Colors.grey[300]!,
                      child: Container(
                        height: 350.h,
                        width: double.infinity,
                        color: Colors.grey[200],
                      ),
                    ),
                    // ❌ الشكل اللي هيظهر لو مفيش نت
                    errorWidget: (context, url, error) => Container(
                      height: 350.h,
                      width: double.infinity,
                      color: const Color(0xFFD7CCC8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: const Color(0xFF2F3E34).withOpacity(0.5),
                            size: 50.r,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "لا يوجد اتصال بالإنترنت",
                            style: TextStyle(
                              fontFamily: 'ElMessiri',
                              fontSize: 14.sp,
                              color: const Color(0xFF2F3E34).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // العنوان تحت الصورة
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ElMessiri',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3E34),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // زرار الإغلاق
          Positioned(
            top: 10.h,
            right: 10.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(5.r),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
