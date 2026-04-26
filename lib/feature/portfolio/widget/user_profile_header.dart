import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProfileHeader extends StatelessWidget {
  final ProfileModel profile;
  final bool isMobile;
  final bool isCollapsed;

  const UserProfileHeader({
    super.key,
    required this.profile,
    required this.isMobile,
    this.isCollapsed = false,
  });

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, 
        insetPadding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زرار القفل فوق الصورة
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // برواز الصورة
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: InteractiveViewer( // عشان لو عايز يزوم وهو فاتحها
                child: CachedNetworkImage(
                  imageUrl: profile.imageUrl,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (profile.imageUrl.isNotEmpty) _showImageDialog(context);
          },
          child: Container(
            padding: EdgeInsets.all(isCollapsed ? 1 : 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF9C5A1A), Color(0xFFD8C9B6)],
              ),
            ),
            child: CircleAvatar(
              radius: isCollapsed ? 18.r : 35.r,
              backgroundColor: const Color(0xFFE8DDCF),
              backgroundImage: profile.imageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(profile.imageUrl)
                  : null,
              child: profile.imageUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      color: const Color(0xFF2F3E34),
                      size: isCollapsed ? 20 : 30,
                    )
                  : null,
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // 2. الاسم والبيو
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.name.isNotEmpty ? profile.name : "Hager Ismail",
                style: TextStyle(
                  fontFamily: 'ElMessiri',
                  fontSize: isCollapsed ? 15.sp : 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              if (!isCollapsed) ...[
                SizedBox(height: 4.h),
                Text(
                  profile.bio,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}