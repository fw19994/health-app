import 'package:flutter/material.dart';
import 'analysis/plan_analysis_screen.dart' as analysis;

/// 计划分析页面
/// 
/// 这是一个转发文件，实际实现在analysis目录中
class PlanAnalysisScreen extends StatelessWidget {
  const PlanAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const analysis.PlanAnalysisScreen();
  }
} 