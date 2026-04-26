import 'package:art_by_hager_ismail/core/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloper extends StatelessWidget {
  AboutDeveloper({super.key});

  // روابط السوشيال ميديا
  final Map<String, String> socialLinks = {
    "WhatsApp": "https://wa.me/201008425325",
    "Facebook": "https://www.facebook.com/share/1AWVXp7rFm/",
    "Instagram": "https://www.instagram.com/youssef_elarabyyy",
    "LinkedIn": "https://www.linkedin.com/in/youssef-e-2a2612234",
    // "TikTok": "https://www.tiktok.com/@youssef_el3rabyy",
    "GitHub": "https://github.com/youssefElaraby",
  };

  // صور السوشيال
  final Map<String, String> socialImages = const {
    "WhatsApp": "assets/image/whatsApp.png",
    "Facebook": "assets/image/facebook.png",
    "Instagram": "assets/image/instgram.png",
    "LinkedIn": "assets/image/linkedin.png",
    // "TikTok": "assets/image/tiktok.png",
    "GitHub": "assets/image/github.png",
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "عن المطور",
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, anim1, anim2) {
            return Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "عن المطور",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "تابعني على السوشيال ميديا وابقى على تواصل!",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),

                      // -------- Social Buttons Grid ----------
                      Wrap(
                        spacing: 20.w,
                        runSpacing: 20.h,
                        alignment: WrapAlignment.center,
                        children: socialLinks.keys.map((key) {
                          return SocialItem(
                            title: key,
                            asset: socialImages[key]!,
                            url: socialLinks[key]!,
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 10.h,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "اغلاق",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return SlideTransition(
              position: Tween(begin: const Offset(0, -1), end: Offset.zero)
                  .animate(
                    CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                  ),
              child: FadeTransition(opacity: anim1, child: child),
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 20.sp),
          SizedBox(width: 6.w),
          Text(
            "عن المطور",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ---------------- Social Item ----------------
class SocialItem extends StatelessWidget {
  final String title;
  final String asset;
  final String? url;

  const SocialItem({
    super.key,
    required this.title,
    required this.asset,
    this.url,
  });

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لا يمكن فتح الرابط، سيتم فتحه في المتصفح")),
        );
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء فتح الرابط")));
      debugPrint("Error opening $url: $e");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (url != null && url!.isNotEmpty) {
          _launchURL(context, url!); // <--- صححت هنا
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("الرابط غير موجود")));
        }
      },
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.12),
            ),
            child: Center(
              child: Image.asset(
                asset,
                width: 35.w,
                height: 35.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
