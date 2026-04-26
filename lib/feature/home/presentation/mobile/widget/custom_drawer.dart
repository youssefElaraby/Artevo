import 'dart:typed_data';
import 'package:art_by_hager_ismail/feature/authentication/sign_up/view_model/auth_states.dart';
import 'package:art_by_hager_ismail/feature/authentication/sign_up/view_model/auth_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/route_manager/routes.dart';
import '../../../../../core/widget/about_developer.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late List<Animation<Offset>> slideAnimations;
  late List<Animation<double>> fadeAnimations;

  // 🔄 متغير لمتابعة حالة الرفع وإظهار اللودنج
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    slideAnimations = List.generate(4, (i) {
      return Tween<Offset>(
        begin: const Offset(-0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(i * .15, 1, curve: Curves.easeOut),
        ),
      );
    });

    fadeAnimations = List.generate(4, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(i * .15, 1, curve: Curves.easeOut),
        ),
      );
    });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 🔥 ميثود التقاط الصورة وتحديثها مع تشغيل اللودنج
  Future<void> _pickAndUpdateImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await pickedFile.readAsBytes();

        await context.read<AuthCubit>().updateProfileImage(bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ تم تحديث الصورة بنجاح"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // 🔥 هنا بقى هيطلعلك السبب لو فيه مشكلة (نت، صلاحيات، Cloudinary)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ فشل الرفع: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  // 🔥 ميثود عرض الصورة بالحجم الكامل
  void _showFullImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.8)),
            ),
            Hero(
              tag: 'profile_pic',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: 0.85.sw,
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBFA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text(
          "تسجيل الخروج",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "هل أنت متأكد أنك تريد مغادرة مَـرسَم؟",
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'ElMessiri'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "إلغاء",
              style: TextStyle(color: Colors.grey, fontFamily: 'ElMessiri'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F3E34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              "خروج",
              style: TextStyle(color: Colors.white, fontFamily: 'ElMessiri'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    return Drawer(
      backgroundColor: const Color(0xFFE8DDCF),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              /// LOGO & Profile Picture
              Center(
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, authSnapshot) {
                    if (authSnapshot.hasData && authSnapshot.data != null) {
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(authSnapshot.data!.uid)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          String? imageUrl;
                          String? fullName;
                          if (userSnapshot.hasData &&
                              userSnapshot.data!.exists) {
                            final userData =
                                userSnapshot.data!.data()
                                    as Map<String, dynamic>;
                            imageUrl = userData['profilePicture'];
                            fullName = userData['fullName'];
                          }

                          return Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _showFullImage(context, imageUrl),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(
                                            0xFF2F3E34,
                                          ).withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: Hero(
                                        tag: 'profile_pic',
                                        child: CircleAvatar(
                                          radius: 40.r,
                                          backgroundColor: const Color(
                                            0xFFD8C9B6,
                                          ),
                                          backgroundImage:
                                              (imageUrl != null &&
                                                  imageUrl.isNotEmpty)
                                              ? NetworkImage(imageUrl)
                                              : null,
                                          child:
                                              (imageUrl == null ||
                                                  imageUrl.isEmpty)
                                              ? Text(
                                                  (fullName != null &&
                                                          fullName.isNotEmpty)
                                                      ? fullName
                                                            .substring(0, 1)
                                                            .toUpperCase()
                                                      : "M",
                                                  style: TextStyle(
                                                    fontSize: 30.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                      0xFF2F3E34,
                                                    ),
                                                    fontFamily: 'ElMessiri',
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 🌀 لودنج الرفع
                                  if (_isUploading)
                                    Container(
                                      width: 88.r,
                                      height: 88.r,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(25.r),
                                        child: const CircularProgressIndicator(
                                          color: Color(0xFFE8DDCF),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              // ✨ زرار إضافة / تغيير الصورة
                              InkWell(
                                onTap: _isUploading
                                    ? null
                                    : () => _pickAndUpdateImage(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (imageUrl != null && imageUrl.isNotEmpty)
                                          ? Icons.cached_rounded
                                          : Icons.add_a_photo_outlined,
                                      size: 14.sp,
                                      color: const Color(0xFF6F624C),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      (imageUrl != null && imageUrl.isNotEmpty)
                                          ? "تغيير الصورة"
                                          : "إضافة صورة",
                                      style: TextStyle(
                                        fontFamily: 'ElMessiri',
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6F624C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundColor: const Color(0xFFD8C9B6),
                        child: Icon(
                          Icons.account_circle,
                          size: 50.sp,
                          color: const Color(0xFF2F3E34),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 10.h),
              Center(
                child: Text(
                  user != null
                      ? "مرحبًا بك ${user.displayName ?? 'فنان مَـرسَم'}"
                      : "مرحبًا بك في مَـرسَم",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ElMessiri',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F3E34),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              /// MAIN MENU
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    AnimatedMenuCard(
                      icon: Icons.home_outlined,
                      title: "الرئيسية",
                      animationSlide: slideAnimations[0],
                      animationFade: fadeAnimations[0],
                      onTap: () => Navigator.pushNamed(
                        context,
                        PageRoutesName.initialHome,
                      ),
                    ),
                    AnimatedMenuCard(
                      icon: Icons.brush_outlined,
                      title: "معرض الأعمال",
                      animationSlide: slideAnimations[1],
                      animationFade: fadeAnimations[1],
                      onTap: () => Navigator.pushNamed(
                        context,
                        PageRoutesName.portfolioRoute,
                      ),
                    ),
                    AnimatedMenuCard(
                      icon: Icons.calendar_today_outlined,
                      title: "احجز سيشن",
                      animationSlide: slideAnimations[2],
                      animationFade: fadeAnimations[2],
                      onTap: () => Navigator.pushNamed(
                        context,
                        PageRoutesName.bookingRoute,
                      ),
                    ),
                    AnimatedMenuCard(
                      icon: Icons.notifications_none_rounded,
                      title: "الأنشطة",
                      animationSlide: slideAnimations[3],
                      animationFade: fadeAnimations[3],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          PageRoutesName.ActivityRoute,
                          arguments: user?.uid,
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
              AboutDeveloper(),
              const Spacer(),

              /// Authentication Section
              if (!isLoggedIn)
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, PageRoutesName.signInRoute),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F3E34),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          "تسجيل الدخول / حساب جديد",
                          style: TextStyle(
                            fontFamily: 'ElMessiri',
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (isLoggedIn)
                BlocListener<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthLoggedOut) {
                      Navigator.pushReplacementNamed(
                        context,
                        PageRoutesName.signInRoute,
                      );
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  child: InkWell(
                    onTap: () => _showLogoutDialog(context),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Text(
                          "تسجيل الخروج",
                          style: TextStyle(
                            fontFamily: 'ElMessiri',
                            fontSize: 13.sp,
                            color: const Color(0xFFD32F2F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Animation<Offset> animationSlide;
  final Animation<double> animationFade;

  const AnimatedMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.animationSlide,
    required this.animationFade,
  });

  @override
  State<AnimatedMenuCard> createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<AnimatedMenuCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animationFade,
      child: SlideTransition(
        position: widget.animationSlide,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => pressed = v),
          child: AnimatedScale(
            scale: pressed ? 0.98 : 1,
            duration: const Duration(milliseconds: 100),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5.h),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, size: 22, color: const Color(0xFF2F3E34)),
                  SizedBox(width: 15.w),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'ElMessiri',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2F3E34),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
