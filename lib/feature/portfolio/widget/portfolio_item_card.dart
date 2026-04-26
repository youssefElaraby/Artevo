import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PortfolioItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isWeb;

  const PortfolioItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 شيلنا الـ Container والـ Column عشان نمنع الـ Overflow للأبد
    return GestureDetector(
      onTap: () => _openFullScreenImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover, // ✅ بتفرش وتملأ المساحة المتاحة لها فقط
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            : Container(color: Colors.grey[300]),
      ),
    );
  }

  // دالة فتح الصورة زووم (منفصلة عشان الكود يبقى نظيف)
  void _openFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              clipBehavior: Clip.none,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // زر إغلاق شيك
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
