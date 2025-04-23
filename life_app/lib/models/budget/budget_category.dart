class BudgetCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final double budget;
  final double spent;
  final double lastMonthSpent;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.budget,
    required this.spent,
    required this.lastMonthSpent,
  });

  // 从JSON创建实例
  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      lastMonthSpent: (json['lastMonthSpent'] as num).toDouble(),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'budget': budget,
      'spent': spent,
      'lastMonthSpent': lastMonthSpent,
    };
  }

  // 创建副本并更新特定字段
  BudgetCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    double? budget,
    double? spent,
    double? lastMonthSpent,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      lastMonthSpent: lastMonthSpent ?? this.lastMonthSpent,
    );
  }

  // 计算预算使用百分比
  double get usagePercentage => budget > 0 ? (spent / budget) * 100 : 0;

  // 计算剩余预算
  double get remainingBudget => budget - spent;

  // 计算与上月相比的变化百分比
  double get monthOverMonthChange => 
    lastMonthSpent > 0 ? ((spent - lastMonthSpent) / lastMonthSpent) * 100 : 0;

  // 检查是否超出预算
  bool get isOverBudget => spent > budget;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          icon == other.icon &&
          color == other.color &&
          budget == other.budget &&
          spent == other.spent &&
          lastMonthSpent == other.lastMonthSpent;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      color.hashCode ^
      budget.hashCode ^
      spent.hashCode ^
      lastMonthSpent.hashCode;
} 