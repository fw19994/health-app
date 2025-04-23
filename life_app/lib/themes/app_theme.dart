import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 主色调 - 更新为橙黄色系
  static const Color primaryColor = Color(0xFFF97316);
  static const Color secondaryColor = Color(0xFFF59E0B);
  
  // 首页样式 - 蓝紫色系
  static const Color homeHeaderLight = Color(0xFF6366F1);
  static const Color homeHeaderDark = Color(0xFF8B5CF6);
  static const LinearGradient homeGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 背景色
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textHint = Color(0xFF999999);
  
  // 功能色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 渐变色 - 更新为橙黄色渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // 功能按钮颜色
  static const Color addButtonBg = Color(0xFFFFF7ED);
  static const Color addButtonIcon = Color(0xFFF97316);
  static const Color budgetButtonBg = Color(0xFFF5F3FF);
  static const Color budgetButtonIcon = Color(0xFF8B5CF6);
  static const Color assistantButtonBg = Color(0xFFEEF2FF);
  static const Color assistantButtonIcon = Color(0xFF6366F1);
  static const Color familyButtonBg = Color(0xFFECFDF5);
  static const Color familyButtonIcon = Color(0xFF10B981);
  
  // 首页健康卡片颜色
  static const Color stepsBg = Color(0xFFEEF2FF);
  static const Color stepsIcon = Color(0xFF6366F1);
  static const Color waterBg = Color(0xFFE0F2FE);
  static const Color waterIcon = Color(0xFF0EA5E9);
  static const Color sleepBg = Color(0xFFF3E8FF);
  static const Color sleepIcon = Color(0xFFA855F7);
  
  // 智能助手"小财"颜色
  static const Color assistantBackground = Color(0xFF6366F1);
  static const Color assistantBubble = Color(0xFFF0EEFF);
  
  // 主题数据
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      useMaterial3: true,
    );
  }
}
