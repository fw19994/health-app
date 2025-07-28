import 'package:flutter/material.dart';

/// 应用通用的提示对话框组件
/// 
/// 用于替代默认的AlertDialog和SnackBar，提供统一的风格
class AppAlertDialog {
  /// 显示提示对话框
  /// 
  /// [context] 上下文
  /// [title] 标题
  /// [message] 消息内容
  /// [primaryButtonText] 主按钮文本，默认为"确定"
  /// [secondaryButtonText] 次要按钮文本，如果为null则不显示次要按钮
  /// [onPrimaryButtonPressed] 点击主按钮时的回调
  /// [onSecondaryButtonPressed] 点击次要按钮时的回调
  /// [barrierDismissible] 点击背景是否关闭对话框
  /// [icon] 图标，默认为警告图标
  /// [accentColor] 强调色，默认为绿色
  static Future<bool?> show({
    required BuildContext context,
    String title = '提示',
    required String message,
    String primaryButtonText = '确定',
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    bool barrierDismissible = true,
    IconData icon = Icons.warning_amber_rounded,
    Color accentColor = const Color(0xFF22c55e),
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            // 如果有次要按钮，显示次要按钮
            if (secondaryButtonText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                  if (onSecondaryButtonPressed != null) {
                    onSecondaryButtonPressed();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
                child: Text(
                  secondaryButtonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            // 主按钮
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                if (onPrimaryButtonPressed != null) {
                  onPrimaryButtonPressed();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
              ),
              child: Text(
                primaryButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 4,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  /// 显示成功提示对话框
  static Future<bool?> showSuccess({
    required BuildContext context,
    String title = '成功',
    required String message,
    String primaryButtonText = '确定',
    VoidCallback? onPrimaryButtonPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      onPrimaryButtonPressed: onPrimaryButtonPressed,
      icon: Icons.check_circle_outline,
      accentColor: const Color(0xFF22c55e),
    );
  }

  /// 显示错误提示对话框
  static Future<bool?> showError({
    required BuildContext context,
    String title = '错误',
    required String message,
    String primaryButtonText = '确定',
    VoidCallback? onPrimaryButtonPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      onPrimaryButtonPressed: onPrimaryButtonPressed,
      icon: Icons.error_outline,
      accentColor: const Color(0xFFef4444),
    );
  }

  /// 显示确认对话框
  static Future<bool?> showConfirmation({
    required BuildContext context,
    String title = '确认',
    required String message,
    String primaryButtonText = '确定',
    String secondaryButtonText = '取消',
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    Color accentColor = const Color(0xFF22c55e),
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryButtonPressed: onPrimaryButtonPressed,
      onSecondaryButtonPressed: onSecondaryButtonPressed,
      icon: Icons.help_outline,
      accentColor: accentColor,
    );
  }
} 