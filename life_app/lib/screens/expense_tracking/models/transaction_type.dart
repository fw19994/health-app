enum TransactionType {
  expense, // 支出
  income,  // 收入
  transfer // 转账
}

extension TransactionTypeExtension on TransactionType {
  String get name {
    switch (this) {
      case TransactionType.expense:
        return '支出';
      case TransactionType.income:
        return '收入';
      case TransactionType.transfer:
        return '转账';
    }
  }
  
  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;
  bool get isTransfer => this == TransactionType.transfer;
}
