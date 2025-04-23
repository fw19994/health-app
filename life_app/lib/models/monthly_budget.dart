import 'budget_category.dart';

class MonthlyBudget {
  final double totalBudget;
  final double totalSpent;
  final double remainingAmount;
  final double usagePercent;
  final List<BudgetCategoryWithUsage> categories;
  final double totalIncome;
  final double changePercent;

  MonthlyBudget({
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingAmount,
    required this.usagePercent,
    required this.categories,
    this.totalIncome = 0.0,
    this.changePercent = 0.0,
  });

  factory MonthlyBudget.fromJson(Map<String, dynamic> json) {
    List<BudgetCategoryWithUsage> categoriesList = [];
    if (json['categories'] != null) {
      for (var item in json['categories']) {
        categoriesList.add(BudgetCategoryWithUsage.fromJson(item));
      }
    }

    return MonthlyBudget(
      totalBudget: json['total_budget']?.toDouble() ?? 0.0,
      totalSpent: json['total_spent']?.toDouble() ?? 0.0,
      remainingAmount: json['remaining_amount']?.toDouble() ?? 0.0,
      usagePercent: json['usage_percent']?.toDouble() ?? 0.0,
      categories: categoriesList,
      totalIncome: json['total_income']?.toDouble() ?? 0.0,
      changePercent: json['change_percent']?.toDouble() ?? 0.0,
    );
  }
}

class BudgetCategoryWithUsage {
  final int id;
  final String name;
  final double amount;
  final double spentAmount;
  final String iconId;
  final String notes;
  final double usagePercent;

  BudgetCategoryWithUsage({
    required this.id,
    required this.name,
    required this.amount,
    required this.spentAmount,
    required this.iconId,
    required this.notes,
    required this.usagePercent,
  });

  factory BudgetCategoryWithUsage.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryWithUsage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      spentAmount: json['spent_amount']?.toDouble() ?? 0.0,
      iconId: json['icon_id']?.toString() ?? '',
      notes: json['notes'] ?? '',
      usagePercent: json['usage_percent']?.toDouble() ?? 0.0,
    );
  }
} 