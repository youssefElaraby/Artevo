import 'package:art_by_hager_ismail/core/resources/color_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CtaBookingButton extends StatelessWidget {
  final VoidCallback onTap;

  const CtaBookingButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;
    final double width = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: isWeb
              ? (width * 0.50) // 🔹 أصغر على الويب
              : (width * 0.75), // 🔹 أعرض على الموبايل

          child: FloatingActionButton.extended(
            heroTag: "cta_booking",
            backgroundColor: Color.fromARGB(255, 50, 67, 56).withOpacity(0.95),
            elevation: 6,
            onPressed: onTap,
            label: Text(
              "احجز الآن",
              style: TextStyle(
                fontSize: isWeb ? 14 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            icon: const Icon(
              Icons.calendar_today,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
