class SavingsGoal {
  final String id;
  final String name;
  final String icon;
  final double targetAmount;
  final double currentAmount;
  final double monthlySaving;
  final DateTime targetDate;
  final String priority;
  final String reminderFrequency;
  final String notes;
  final bool remindersEnabled;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlySaving,
    required this.targetDate,
    required this.priority,
    required this.reminderFrequency,
    required this.notes,
    required this.remindersEnabled,
  });

  double get progress => currentAmount / targetAmount;
  
  int get remainingMonths {
    final remaining = targetAmount - currentAmount;
    return (remaining / monthlySaving).ceil();
  }

  int get remainingDays {
    return targetDate.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'monthlySaving': monthlySaving,
    'targetDate': targetDate.toIso8601String(),
    'priority': priority,
    'reminderFrequency': reminderFrequency,
    'notes': notes,
    'remindersEnabled': remindersEnabled,
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount'].toDouble(),
    monthlySaving: json['monthlySaving'].toDouble(),
    targetDate: DateTime.parse(json['targetDate']),
    priority: json['priority'],
    reminderFrequency: json['reminderFrequency'],
    notes: json['notes'],
    remindersEnabled: json['remindersEnabled'],
  );
} 