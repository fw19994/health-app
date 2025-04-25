import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'models/transaction_type.dart';
import 'models/transaction_category.dart';
import 'models/transaction.dart';
import 'models/account.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/amount_input.dart';
import 'widgets/category_selector.dart';
import 'widgets/form_field_item.dart';
import 'widgets/family_expense_toggle.dart';
import 'widgets/receipt_photo_button.dart';
import 'widgets/recent_transaction_suggestions.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialAccountId;
  final double? initialAmount;
  final bool isEdit;
  final Transaction? transaction;
  
  const ExpenseTrackingScreen({
    super.key,
    this.initialCategoryId,
    this.initialAccountId,
    this.initialAmount,
    this.isEdit = false,
    this.transaction,
  });

  @override
  State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  late TransactionType _transactionType;
  late TransactionCategory? _selectedCategory;
  late List<Transaction> _recentTransactions;
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late String _selectedAccountId;
  late bool _isFamilyExpense;
  String? _receiptPhotoUrl;
  
  double _currentBalance = 5245.75;
  double _remainingBudget = 1755.00;

  @override
  void initState() {
    super.initState();
    
    // 初始化交易类型
    _transactionType = widget.transaction?.type ?? TransactionType.expense;
    
    // 初始化所选类别
    if (widget.transaction != null) {
      _selectedCategory = widget.transaction!.category;
    } else if (widget.initialCategoryId != null) {
      _selectedCategory = TransactionCategories.getCategoryById(widget.initialCategoryId!);
    } else {
      _selectedCategory = _transactionType == TransactionType.expense 
          ? TransactionCategories.food
          : _transactionType == TransactionType.income
              ? TransactionCategories.salary
              : TransactionCategories.transfer;
    }
    
    // 初始化金额控制器
    _amountController = TextEditingController();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
    } else if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount.toString();
    }
    
    // 初始化商家和备注控制器
    _merchantController = TextEditingController(text: widget.transaction?.merchant ?? '');
    _noteController = TextEditingController(text: widget.transaction?.note ?? '');
    
    // 初始化日期
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    
    // 初始化账户
    if (widget.transaction != null) {
      _selectedAccountId = widget.transaction!.account.id;
    } else if (widget.initialAccountId != null) {
      _selectedAccountId = widget.initialAccountId!;
    } else {
      _selectedAccountId = AccountTypes.bankAccount.id;
    }
    
    // 初始化家庭支出标志
    _isFamilyExpense = widget.transaction?.isFamilyExpense ?? false;
    
    // 初始化收据照片URL
    _receiptPhotoUrl = widget.transaction?.receiptImageUrl;
    
    // 获取近期交易
    _recentTransactions = MockTransactions.getRecentTransactions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTransactionTypeChanged(TransactionType type) {
    if (type != _transactionType) {
      setState(() {
        _transactionType = type;
        
        // 根据交易类型更新默认类别
        _selectedCategory = type == TransactionType.expense 
            ? TransactionCategories.food
            : type == TransactionType.income
                ? TransactionCategories.salary
                : TransactionCategories.transfer;
      });
    }
  }

  void _onCategorySelected(TransactionCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onAmountChanged(double amount) {
    // 金额已在输入框中更新，无需额外处理
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onAccountChanged(String accountId) {
    setState(() {
      _selectedAccountId = accountId;
    });
  }

  void _onFamilyExpenseToggle(bool value) {
    setState(() {
      _isFamilyExpense = value;
    });
  }

  void _onAddReceiptPhoto() {
    // TODO: 实现添加收据照片功能
    setState(() {
      _receiptPhotoUrl = 'https://example.com/receipt.jpg'; // 模拟添加照片
    });
  }

  void _onTransactionSuggestionSelected(Transaction transaction) {
    setState(() {
      _amountController.text = transaction.amount.toString();
      _selectedCategory = transaction.category;
      _merchantController.text = transaction.merchant ?? '';
      _noteController.text = transaction.note ?? '';
      _isFamilyExpense = transaction.isFamilyExpense;
    });
  }

  void _saveTransaction() {
    // 验证输入
    if (_amountController.text.isEmpty || double.parse(_amountController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的金额')),
      );
      return;
    }
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择交易类别')),
      );
      return;
    }
    
    // 构建交易对象
    final transaction = Transaction(
      id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text),
      type: _transactionType,
      category: _selectedCategory!,
      account: AccountTypes.getAccountById(_selectedAccountId)!,
      date: _selectedDate,
      merchant: _merchantController.text.isNotEmpty ? _merchantController.text : null,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      isFamilyExpense: _isFamilyExpense,
      receiptImageUrl: _receiptPhotoUrl,
    );
    
    // TODO: 保存交易到数据库
    
    // 返回上一页
    Navigator.of(context).pop(transaction);
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前选中账户
    final selectedAccount = AccountTypes.getAccountById(_selectedAccountId)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 标题栏
          _buildHeader(),
          
          // 主内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 交易类型切换
                  TransactionTypeToggle(
                    selectedType: _transactionType,
                    onTypeChanged: _onTransactionTypeChanged,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 表单卡片
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 金额输入
                        AmountInput(
                          controller: _amountController,
                          onAmountChanged: _onAmountChanged,
                        ),
                        
                        // 类别选择
                        CategorySelector(
                          transactionType: _transactionType,
                          selectedCategory: _selectedCategory,
                          onCategorySelected: _onCategorySelected,
                          onAddCategory: (name, icon, color) {
                            // 实现添加自定义类别的逻辑
                            // 这里可以根据具体需求调用相应的API或更新本地状态
                            // 例如：
                            final newCategory = TransactionCategory(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: name,
                              icon: icon,
                              color: color,
                              backgroundColor: color.withOpacity(0.1),
                              type: _transactionType,
                            );
                            
                            setState(() {
                              // 将新类别添加到类别列表中
                              // 这里需要根据实际的数据管理方式进行调整
                              // 如果有API调用，则需要先调用API再更新本地状态
                              TransactionCategories.addCustomCategory(newCategory);
                              _selectedCategory = newCategory; // 自动选择新创建的类别
                            });
                          },
                        ),
                        
                        // 日期选择
                        DateFormField(
                          date: _selectedDate,
                          onDateChanged: _onDateChanged,
                        ),
                        
                        // 账户选择
                        AccountFormField(
                          value: selectedAccount.displayName,
                          options: AccountTypes.getAllAccounts().map((a) => a.displayName).toList(),
                          onChanged: (value) {
                            final account = AccountTypes.getAllAccounts().firstWhere(
                              (a) => a.displayName == value,
                            );
                            _onAccountChanged(account.id);
                          },
                        ),
                        
                        // 商家输入
                        TextFormFieldItem(
                          icon: FontAwesomeIcons.store,
                          label: '商家',
                          placeholder: '输入商家名称',
                          controller: _merchantController,
                          onChanged: (value) {},
                        ),
                        
                        // 备注输入
                        TextFormFieldItem(
                          icon: FontAwesomeIcons.stickyNote,
                          label: '备注',
                          placeholder: '添加备注',
                          controller: _noteController,
                          onChanged: (value) {},
                        ),
                        
                        // 收据照片按钮
                        ReceiptPhotoButton(
                          onTap: _onAddReceiptPhoto,
                          photoUrl: _receiptPhotoUrl,
                        ),
                        
                        // 家庭支出切换
                        FamilyExpenseToggle(
                          isFamilyExpense: _isFamilyExpense,
                          onChanged: _onFamilyExpenseToggle,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 近期类似交易建议
                  if (_transactionType == TransactionType.expense)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: RecentTransactionSuggestions(
                        transactions: _recentTransactions,
                        onTransactionSelected: _onTransactionSuggestionSelected,
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // 保存按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.isEdit ? '更新' : '保存',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮和标题
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '记一笔',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // 副标题
          const Text(
            '记录您的收入和支出',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
