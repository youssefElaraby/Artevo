import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:art_by_hager_ismail/core/resources/color_manager.dart';

class MobileFloatingCard extends StatelessWidget {
  const MobileFloatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        if (!isMobile) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 180.h,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryDark.withOpacity(0.2),
                  AppColors.primaryLight.withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [

                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                      bottomRight: Radius.circular(30.r),
                    ),
                    child: Opacity(
                      opacity: 0.9,
                      child: kIsWeb
                          ? Transform.translate(
                        offset: const Offset(0, -50),
                        child: Lottie.network(
                          'assets/image/wave.json', // Web
                          fit: BoxFit.cover,
                          repeat: true,
                        ),
                      )
                          : Lottie.asset(
                        'assets/image/wave.json', // Mobile
                        fit: BoxFit.cover,
                        repeat: true,
                      ),
                    ),

                  ),
                ),

                // زر Drawer
                Positioned(
                  top: 130.h,
                  left: 8.w,
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, size: 30, color: AppColors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),

                // ظل تحت الكارد
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 6.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
