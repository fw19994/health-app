import 'package:flutter/material.dart';
import '../../themes/budget_theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? fillColor;
  final double height;
  final double borderRadius;

  const ProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor,
    this.fillColor,
    this.height = 8.0,
    this.borderRadius = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? BudgetTheme.progressBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor ?? BudgetTheme.progressFillColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
} 