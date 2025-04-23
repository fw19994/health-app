import 'package:flutter/material.dart';

class IncomeSource {
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  
  const IncomeSource({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
