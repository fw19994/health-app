import 'package:intl/intl.dart';
import 'transaction_type.dart';
import 'transaction_category.dart';
import 'account.dart';

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final Account account;
  final DateTime date;
  final String? merchant;
  final String? note;
  final bool isFamilyExpense;
  final String? receiptImageUrl;
  final String? familyMemberId;
  
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.account,
    required this.date,
    this.merchant,
    this.note,
    this.isFamilyExpense = false,
    this.receiptImageUrl,
    this.familyMemberId,
  });
  
  // 格式化金额显示
  String get formattedAmount {
    final formatter = NumberFormat('#,##0.00');
    return '¥${formatter.format(amount)}';
  }
  
  // 格式化日期显示
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // 复制并修改交易记录
  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    Account? account,
    DateTime? date,
    String? merchant,
    String? note,
    bool? isFamilyExpense,
    String? receiptImageUrl,
    String? familyMemberId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      account: account ?? this.account,
      date: date ?? this.date,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      isFamilyExpense: isFamilyExpense ?? this.isFamilyExpense,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      familyMemberId: familyMemberId ?? this.familyMemberId,
    );
  }
}

// 示例交易数据
class MockTransactions {
  static List<Transaction> getRecentTransactions() {
    return [
      Transaction(
        id: '1',
        amount: 2800,
        type: TransactionType.expense,
        category: TransactionCategories.housing,
        account: AccountTypes.bankAccount,
        date: DateTime.now().subtract(const Duration(days: 5)),
        merchant: '业主委员会',
        note: '四月份房租',
        isFamilyExpense: true,
      ),
      Transaction(
        id: '2',
        amount: 230,
        type: TransactionType.expense,
        category: TransactionCategories.utilities,
        account: AccountTypes.alipay,
        date: DateTime.now().subtract(const Duration(days: 3)),
        merchant: '电力公司',
        note: '三月份水电费',
        isFamilyExpense: true,
      ),
      Transaction(
        id: '3',
        amount: 150,
        type: TransactionType.expense,
        category: TransactionCategories.housing,
        account: AccountTypes.wechat,
        date: DateTime.now().subtract(const Duration(days: 10)),
        merchant: '物业公司',
        note: '三月份物业费',
        isFamilyExpense: true,
      ),
    ];
  }
}
