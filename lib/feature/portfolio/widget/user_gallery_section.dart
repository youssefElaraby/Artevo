import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tilt/flutter_tilt.dart'; // ✅ أضفنا الباكدج هنا

class UserGallerySection extends StatelessWidget {
  final List<ArtworkModel> artworks;
  final bool isMobile;
  final bool isWeb;

  const UserGallerySection({
    super.key,
    required this.artworks,
    required this.isMobile,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "معرض الأعمال الفنية",
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.w900,
            fontSize: isWeb ? 22 : 20.sp,
            color: const Color(0xFF2F3E34),
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            mainAxisSpacing: 15.h,
            crossAxisSpacing: 15.w,
            childAspectRatio: isMobile ? 0.75 : 1.1,
          ),
          itemCount: artworks.length,
          itemBuilder: (_, i) => _ArtisticCard(art: artworks[i], isWeb: isWeb),
        ),
      ],
    );
  }
}

class _ArtisticCard extends StatelessWidget {
  final ArtworkModel art;
  final bool isWeb;

  const _ArtisticCard({required this.art, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    // ✅ استخدمنا Tilt هنا عشان نحول الكارت لـ 3D
    return Tilt(
      tiltConfig: const TiltConfig(
        angle: 15, // زاوية الميل
        enableRevert: true, // يرجع مكانه لما تشيل إيدك
        moveDuration: Duration(milliseconds: 500),
      ),
      lightConfig: const LightConfig(
        color: Colors.white,
        minIntensity: 0.1,
        maxIntensity: 0.5,
      ),
      shadowConfig: ShadowConfig(
        color: const Color(0xFF2F3E34).withOpacity(0.2),
      ),
      child: GestureDetector(
        onTap: () => _openDetails(context),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.r)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: Stack(
              children: [
                // 1. الصورة
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: art.images.isNotEmpty ? art.images.first : '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.black12),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),
                ),

                // 2. تظليل فني سفلي
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. النصوص
                Positioned(
                  bottom: 12.h,
                  right: 12.w,
                  left: 12.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        art.title,
                        style: TextStyle(
                          fontFamily: 'ElMessiri',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        art.description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9.sp,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: art.images.first,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
