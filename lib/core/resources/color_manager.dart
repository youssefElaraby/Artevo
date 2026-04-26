import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF004182); // أزرق هادئ
  static const Color primaryDark = Color(0xFF06004F);  // أزرق غامق للـ AppBar أو Text
  static const Color primaryLight = Color(0xFF5A7DD3); // أزرق فاتح للـ Buttons/Highlights

  // Accent Colors
  static const Color yellowAccent = Color(0xFFFDD835); // لتقييم النجوم أو عناصر بارزة
  static const Color orangeAccent = Color(0xFFD17D11); // ألوان ثانوية للمحتوى أو الـ Buttons
  static const Color orangeLight = Color(0xCCD17D11); // لون شفاف للـ Backgrounds

  // Text Colors
  static const Color textPrimary = Color(0xFF06004F); // أساسي للنصوص
  static const Color textSecondary = Color(0xFF525252); // ثانوي للنصوص الصغيرة
  static const Color textGrey = Color(0xFF737477);      // نصوص ثانوية أخف
  static const Color textWhite = Color(0xFFFFFFFF);

  // Background / Containers
  static const Color containerGray = Color(0xFFDBE4ED);
  static const Color lightGrey = Color(0xFF9E9E9E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // Error / Warning
  static const Color error = Color(0xFFE61F34); // للـ Form validation أو الأخطاء

  // Optional / Additional
  static const Color darkBlue = Color(0xFF06004F); // استخدام متكرر للـ UI
  static const Color grey1 = Color(0xFF707070);
  static const Color grey2 = Color(0xFF797979);
  static const Color starRateColor = Color(0xFFFDD835); // نجوم التقييم

  static const Color moss = Color(0xFF2F3E34);      // أخضر غامق
  static const Color autumn = Color(0xFF9C5A1A);    // أورانج محروق
  static const Color prairie = Color(0xFF6F624C);   // بني متوسط
  static const Color wheat = Color(0xFFE8DDCF);     // بيج فاتح (خلفية)
  static const Color sand = Color(0xFFD8C9B6);      // بيج غامق (حدود)

}
