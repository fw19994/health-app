import 'package:flutter/material.dart';

class BudgetTheme {
  // 颜色
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF9333EA);
  static const Color successColor = Color(0xFF16A34A);
  static const Color warningColor = Color(0xFFD97706);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF111827);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);

  // 间距
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // 圆角
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // 字体样式
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  // 阴影
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // 输入框装饰
  static InputDecoration get inputDecoration => InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
      borderSide: const BorderSide(color: dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
      borderSide: const BorderSide(color: dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
      borderSide: const BorderSide(color: primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
      borderSide: const BorderSide(color: errorColor),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingMedium,
      vertical: spacingSmall,
    ),
  );

  // 按钮样式
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLarge,
      vertical: spacingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLarge,
      vertical: spacingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
      side: const BorderSide(color: primaryColor),
    ),
  );

  // 进度条颜色
  static const Color progressBackgroundColor = Color(0xFFE5E7EB);
  static const Color progressFillColor = primaryColor;
  
  // 卡片样式
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: cardShadow,
  );
  
  // 图标尺寸
  static const double iconSizeLarge = 32.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeSmall = 16.0;
} 