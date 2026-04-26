import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_manager.dart';

class ApplicationThemeManager {
  static final ThemeData themeData = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.white,

    // ==========================================================
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.elMessiri(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: GoogleFonts.elMessiri(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.elMessiri(
        color: AppColors.textGrey,
        fontSize: 12,
        fontWeight: FontWeight.w200,
      ),
      displaySmall: GoogleFonts.elMessiri(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    // ==========================================================
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedIconTheme: IconThemeData(
        size: 30,
        color: AppColors.primaryColor,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColors.grey1,
      ),
      showUnselectedLabels: false,
    ),
    // ==========================================================
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
        side: BorderSide(
          color: AppColors.white,
          width: 4,
        ),
      ),
      sizeConstraints: const BoxConstraints(
        minWidth: 70,
        minHeight: 70,
        maxWidth: 100,
        maxHeight: 100,
      ),
    ),
    // ==========================================================
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(
          color: AppColors.containerGray,
          width: 1,
        ),
      ),
    ),
    // ==========================================================
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
    ),
  );
}
