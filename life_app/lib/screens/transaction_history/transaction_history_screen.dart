import 'package:flutter/material.dart';
import 'widgets/transaction_header.dart';
import 'widgets/transaction_filters.dart';
import 'widgets/transaction_tabs.dart';
import 'widgets/transaction_summary.dart';
import 'widgets/transaction_trend_chart.dart';
import 'widgets/member_contribution.dart';
import 'widgets/transaction_list.dart';
import 'models/transaction.dart';
import 'models/filter_options.dart';
import '../../models/family_member_model.dart';
import '../../services/family_member_service.dart';
import '../../services/finance_service.dart';
import '../../services/icon_service.dart';
import '../../models/icon.dart';
import '../member_finances/models/family_member.dart' as chart_models;
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? initialMemberId;
  final FilterOptions? initialFilters;
  
  const TransactionHistoryScreen({
    super.key, 
    this.initialMemberId,
    this.initialFilters,
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  FamilyMember? _selectedMember;
  bool _isLoadingInitialMember = false;
  bool _isLoadingTransactions = false;
  bool _isLoadingMoreTransactions = false;
  TransactionFilter _selectedTab = TransactionFilter.all;
  
  // 当前页码，用于分页加载
  int _currentPage = 1;
  // 每页加载的数据条数
  final int _pageSize = 30;
  // 是否还有更多数据
  bool _hasMoreData = true;
  
  // 筛选条件
  FilterOptions _filterOptions = const FilterOptions();
  
  // 交易数据
  final List<TransactionDateGroup> _transactionGroups = [];
  int _transactionCount = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  
  // 趋势图数据
  List<double> _incomeData = [1500, 2300, 1800, 2500];
  List<double> _expenseData = [1200, 1800, 1500, 2000];
  List<String> _trendLabels = ['第1周', '第2周', '第3周', '第4周'];
  
  // 成员贡献数据
  List<FamilyMember> _familyMembers = [];
  // 用于成员贡献图表的数据
  List<chart_models.FamilyMember> _chartMembers = [];
  
  // 财务服务实例
  final FinanceService _financeService = FinanceService();
  // 图标服务实例
  final IconService _iconService = IconService();
  // 缓存已加载的图标，避免重复请求
  final Map<int, IconModel> _iconCache = {};

  @override
  void initState() {
    super.initState();
    
    debugPrint('【交易记录页面】初始化开始');
    debugPrint('【交易记录页面】接收到的initialMemberId: ${widget.initialMemberId}');
    if (widget.initialFilters != null) {
      debugPrint('【交易记录页面】接收到的initialFilters: ${widget.initialFilters!.memberId}, period: ${widget.initialFilters!.period}');
    } else {
      debugPrint('【交易记录页面】没有接收到initialFilters');
    }
    
    // 如果提供了初始筛选条件，应用它
    if (widget.initialFilters != null) {
      _filterOptions = widget.initialFilters!;
      debugPrint('应用初始筛选条件: ${_filterOptions.toJson()}');
    }
    
    // 如果提供了初始成员ID，就加载该成员
    if (widget.initialMemberId != null) {
      debugPrint('【交易记录页面】有initialMemberId，准备加载初始成员');
      _loadInitialMember(); // 在_loadInitialMember方法内会调用_loadTransactionData
    } else {
      // 只有当没有初始成员ID时才直接加载交易数据
      debugPrint('【交易记录页面】无initialMemberId，直接加载交易数据');
      _loadTransactionData();
    }
    
    // 加载成员数据
    _loadFamilyMembersData();
    
    debugPrint('交易记录页面初始化，initialMemberId: ${widget.initialMemberId}');
  }
  
  // 加载初始成员数据
  Future<void> _loadInitialMember() async {
    debugPrint('【交易记录页面】开始加载初始成员，ID: ${widget.initialMemberId}');
    setState(() {
      _isLoadingInitialMember = true;
    });
    
    try {
      final familyMemberService = FamilyMemberService(context: context);
      final response = await familyMemberService.getFamilyMembers();
      
      debugPrint('【交易记录页面】加载家庭成员结果，成功: ${response.success}, 成员数量: ${response.data?.length ?? 0}');
      
      if (response.success && mounted) {
        final members = response.data ?? [];
        if (members.isNotEmpty) {
          debugPrint('【交易记录页面】开始查找匹配成员，初始ID: ${widget.initialMemberId}');
          debugPrint('【交易记录页面】所有成员ID列表: ${members.map((m) => m.id.toString()).toList()}');
          debugPrint('【交易记录页面】所有成员角色列表: ${members.map((m) => m.role.toLowerCase()).toList()}');
          
          // 如果已经在筛选条件中指定了成员ID，直接使用该ID查找成员
          if (_filterOptions.memberId != null && _filterOptions.memberId!.isNotEmpty) {
            debugPrint('【交易记录页面】从筛选条件找到memberId: ${_filterOptions.memberId}');
            
            // 在成员列表中查找匹配的成员
            final matchingMembers = members.where((m) => m.id.toString() == _filterOptions.memberId).toList();
            if (matchingMembers.isNotEmpty) {
              setState(() {
                _selectedMember = matchingMembers.first;
              });
              debugPrint('【交易记录页面】通过筛选条件ID找到成员: ${_selectedMember?.name}, ID: ${_selectedMember?.id}');
            } else {
              debugPrint('【交易记录页面】通过筛选条件ID未找到匹配成员: ${_filterOptions.memberId}');
            }
          } 
          // 如果筛选条件中没有成员ID，则使用initialMemberId查找
          else {
            // 首先尝试通过ID匹配成员
            bool foundById = false;
          for (var member in members) {
              debugPrint('【交易记录页面】检查成员: ${member.name}, ID: ${member.id}, 角色: ${member.role}');
              debugPrint('【交易记录页面】比较: "${member.id.toString()}" == "${widget.initialMemberId}"');
              
              if (member.id.toString() == widget.initialMemberId) {
                debugPrint('【交易记录页面】ID匹配成功');
                setState(() {
                  _selectedMember = member;
                  // 更新筛选条件
                  _filterOptions = _filterOptions.copyWith(
                    memberId: member.id.toString(),
                  );
                });
                debugPrint('【交易记录页面】找到匹配的成员(通过ID): ${member.name}, ID: ${member.id}');
                foundById = true;
                break;
              } else {
                debugPrint('【交易记录页面】ID不匹配');
              }
            }
            
            // 如果没有通过ID找到，尝试通过角色名称匹配（兼容旧代码）
            if (!foundById) {
              debugPrint('【交易记录页面】通过ID未找到匹配成员，尝试通过角色匹配');
              for (var member in members) {
                debugPrint('【交易记录页面】比较角色: "${member.role.toLowerCase()}" == "${widget.initialMemberId?.toLowerCase()}"');
            if (member.role.toLowerCase() == widget.initialMemberId?.toLowerCase()) {
                  debugPrint('【交易记录页面】角色匹配成功');
              setState(() {
                _selectedMember = member;
                // 更新筛选条件
                _filterOptions = _filterOptions.copyWith(
                  memberId: member.id.toString(),
                );
              });
                  debugPrint('【交易记录页面】找到匹配的成员(通过角色): ${member.name}, ID: ${member.id}, 角色: ${member.role}');
              break;
                } else {
                  debugPrint('【交易记录页面】角色不匹配');
                }
              }
            }
          }
          
          if (_selectedMember == null) {
            debugPrint('【交易记录页面】通过ID和角色均未找到匹配的成员');
          } else {
            debugPrint('【交易记录页面】最终选中成员: ${_selectedMember?.name}, ID: ${_selectedMember?.id}, 角色: ${_selectedMember?.role}');
            debugPrint('【交易记录页面】最终筛选条件: memberId=${_filterOptions.memberId}');
          }
        }
      }
    } catch (e) {
      debugPrint('【交易记录页面】加载初始成员失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialMember = false;
        });
        
        // 在加载成员完成后，无论成功与否，都加载一次交易数据
        debugPrint('【交易记录页面】加载成员完成，准备加载交易数据');
        _loadTransactionData();
      }
    }
  }
  
  // 成员选择回调 - 仅用于TransactionHeader
  void _onMemberSelected(FamilyMember? member) {
    debugPrint('选择成员: ${member?.name ?? '全部'}');
    setState(() {
      _selectedMember = member;
      // 更新筛选条件中的成员ID
      _filterOptions = _filterOptions.copyWith(
        memberId: member?.id.toString(),
      );
    });
    // 根据选择的成员筛选交易记录
    _loadTransactionData();
  }
  
  // 选项卡切换回调
  void _onTabSelected(TransactionFilter filter) {
    debugPrint('选择标签: $filter');
    setState(() {
      _selectedTab = filter;
      // 更新筛选条件中的交易类型
      _filterOptions = _filterOptions.copyWith(
        transactionType: filter,
      );
    });
    // 根据选择的过滤条件筛选交易记录
    _loadTransactionData();
  }
  
  // 筛选条件变化回调
  void _onFilterChanged(FilterOptions newFilters) {
    debugPrint('筛选条件变化: ${newFilters.toJson()}');
    // 如果筛选条件发生了变化
    if (_filterOptions != newFilters) {
      setState(() {
        _filterOptions = newFilters;
      });
      // 重新加载交易数据
      _loadTransactionData();
    }
  }
  
  // 从后端加载交易数据
  Future<void> _loadTransactionData({bool loadMore = false}) async {
    // 如果是加载更多，但已经没有更多数据，直接返回
    if (loadMore && !_hasMoreData) {
      debugPrint('没有更多数据可加载');
      return;
    }
    
    // 如果已经在加载中，不要重复加载
    if ((_isLoadingTransactions || _isLoadingMoreTransactions) && !loadMore) {
      debugPrint('⚠️ 已经有正在进行的数据加载请求，跳过重复调用');
      return;
    }
    
    // 如果不是加载更多，重置页码和更多数据标志
    if (!loadMore) {
      _currentPage = 1;
      _hasMoreData = true;
    }
    
    // 确保成员ID正确传递
    String? memberIdParam = null;
    if (_selectedMember != null) {
      memberIdParam = _selectedMember!.id.toString();
      debugPrint('使用选中成员ID: $memberIdParam, 成员名称: ${_selectedMember!.name}');
    } else if (_filterOptions.memberId != null && _filterOptions.memberId!.isNotEmpty) {
      memberIdParam = _filterOptions.memberId;
      debugPrint('使用筛选条件中的成员ID: $memberIdParam');
    }
    
    debugPrint('${loadMore ? "加载更多" : "加载"} 交易数据，当前页码: $_currentPage，筛选条件: ${_filterOptions.toJson()}, 选择的成员ID: $memberIdParam');
    
    setState(() {
      if (loadMore) {
        _isLoadingMoreTransactions = true;
      } else {
        _isLoadingTransactions = true;
      }
    });
    
    try {
      // 准备查询参数
      String? transactionType;
      switch (_selectedTab) {
        case TransactionFilter.income:
          transactionType = 'income';
          break;
        case TransactionFilter.expense:
          transactionType = 'expense';
          break;
        case TransactionFilter.all:
          transactionType = null; // 不过滤类型
          break;
      }
      
      // 设置日期范围
      DateTime? startDate;
      DateTime? endDate;
      
      // 根据筛选条件中的时间段设置日期范围
      if (_filterOptions.period != FilterPeriod.custom || _filterOptions.customDateRange == null) {
        final now = DateTime.now();
        // 设置结束日期为今天的23:59:59
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        
        switch (_filterOptions.period) {
          case FilterPeriod.last7Days:
            // 设置开始日期为7天前的00:00:00
            startDate = DateTime(now.year, now.month, now.day - 7, 0, 0, 0);
            break;
          case FilterPeriod.last30Days:
            // 设置开始日期为30天前的00:00:00
            startDate = DateTime(now.year, now.month, now.day - 30, 0, 0, 0);
            break;
          case FilterPeriod.last3Months:
            // 设置开始日期为3个月前的00:00:00
            startDate = DateTime(now.year, now.month - 3, now.day, 0, 0, 0);
            break;
          case FilterPeriod.last6Months:
            // 设置开始日期为6个月前的00:00:00
            startDate = DateTime(now.year, now.month - 6, now.day, 0, 0, 0);
            break;
          case FilterPeriod.last12Months:
            // 设置开始日期为12个月前的00:00:00
            startDate = DateTime(now.year - 1, now.month, now.day, 0, 0, 0);
            break;
          case FilterPeriod.thisMonth:
            // 设置开始日期为本月1号的00:00:00
            startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
            break;
          case FilterPeriod.lastMonth:
            // 设置开始日期为上个月1号的00:00:00
            startDate = DateTime(now.year, now.month - 1, 1, 0, 0, 0);
            // 设置结束日期为上个月最后一天的23:59:59
            endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
            break;
          case FilterPeriod.thisYear:
            // 设置开始日期为今年1月1号的00:00:00
            startDate = DateTime(now.year, 1, 1, 0, 0, 0);
            break;
          case FilterPeriod.lastYear:
            // 设置开始日期为去年1月1号的00:00:00
            startDate = DateTime(now.year - 1, 1, 1, 0, 0, 0);
            // 设置结束日期为去年12月31号的23:59:59
            endDate = DateTime(now.year, 1, 0, 23, 59, 59);
            break;
          case FilterPeriod.custom:
            // 默认30天情况下，设置开始日期为30天前的00:00:00
            startDate = DateTime(now.year, now.month, now.day - 30, 0, 0, 0);
            break;
        }
      } else {
        // 使用自定义日期范围，设置具体的时间
        startDate = DateTime(
          _filterOptions.customDateRange!.start.year,
          _filterOptions.customDateRange!.start.month,
          _filterOptions.customDateRange!.start.day,
          0, 0, 0 // 设置为当天的00:00:00
        );
        
        endDate = DateTime(
          _filterOptions.customDateRange!.end.year,
          _filterOptions.customDateRange!.end.month,
          _filterOptions.customDateRange!.end.day,
          23, 59, 59 // 设置为当天的23:59:59
        );
      }
      
      debugPrint('加载交易数据: 类型=$transactionType, 开始日期=$startDate, 结束日期=$endDate, 成员ID=$memberIdParam, 分类IDs=${_filterOptions.categoryIds}');
      
      // 仅在首次加载时调用获取摘要数据接口
      if (!loadMore) {
        // 调用财务服务获取交易统计数据
        final response = await _financeService.getTransactionSummary(
          context: context,
          startDate: startDate,
          endDate: endDate,
          type: transactionType,
          memberId: memberIdParam != null ? int.tryParse(memberIdParam) : null,
          categoryIds: _filterOptions.categoryIds.isNotEmpty ? 
            _parseFilterCategoryIds(_filterOptions.categoryIds) : 
            null,
          familyId: null, // 如果需要家庭ID过滤，在这里添加
        );
        
        if (response.success && mounted) {
          // 解析API返回的数据
          final summaryData = response.data;
          
          if (summaryData != null) {
            setState(() {
              // 更新统计摘要数据 - 增强解析逻辑
              try {
                // 解析总笔数
                final countValue = summaryData['summary']['total_count'];
                if (countValue is num) {
                  _transactionCount = countValue.toInt();
                } else if (countValue is String) {
                  _transactionCount = int.tryParse(countValue) ?? 0;
                } else {
                  _transactionCount = 0;
                }
                
                // 解析总收入
                final incomeValue = summaryData['summary']['total_income'];
                if (incomeValue is num) {
                  _totalIncome = incomeValue.toDouble();
                } else if (incomeValue is String) {
                  _totalIncome = double.tryParse(incomeValue.replaceAll(',', '').trim()) ?? 0;
                } else {
                  _totalIncome = 0;
                }
                
                // 解析总支出
                final expenseValue = summaryData['summary']['total_expense'];
                if (expenseValue is num) {
                  _totalExpense = expenseValue.toDouble();
                } else if (expenseValue is String) {
                  _totalExpense = double.tryParse(expenseValue.replaceAll(',', '').trim()) ?? 0;
                } else {
                  _totalExpense = 0;
                }
              } catch (e) {
                debugPrint('解析交易摘要数据出错: $e');
                _transactionCount = 0;
                _totalIncome = 0;
                _totalExpense = 0;
              }
            });
            
            debugPrint('交易数据加载成功: 总笔数=$_transactionCount, 总收入=$_totalIncome, 总支出=$_totalExpense');
          }
        } else {
          debugPrint('交易摘要数据加载失败: ${response.message}');
          
          // 显示错误提示（可选）
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('摘要数据加载失败: ${response.message}')),
            );
          }
        }
      }
      
      // 调用财务服务获取交易记录分组数据
      final groupsResponse = await _financeService.getTransactionGroups(
        context: context,
        startDate: startDate,
        endDate: endDate,
        type: transactionType,
        memberId: memberIdParam != null ? int.tryParse(memberIdParam) : null,
        categoryIds: _filterOptions.categoryIds.isNotEmpty ? 
          _parseFilterCategoryIds(_filterOptions.categoryIds) : 
          null,
        familyId: null, // 如果需要家庭ID过滤，在这里添加
        limit: _pageSize, // 每次加载30条数据
        page: _currentPage, // 添加页码参数
      );
      
      // 仅在首次加载时调用获取趋势图数据
      if (!loadMore) {
        // 同时获取趋势图数据
        final trendResponse = await _financeService.getTransactionTrend(
          context: context,
          startDate: startDate,
          endDate: endDate,
          interval: _getTrendInterval(startDate, endDate),
          type: transactionType,
          memberId: memberIdParam != null ? int.tryParse(memberIdParam) : null,
          categoryIds: _filterOptions.categoryIds.isNotEmpty ? 
            _parseFilterCategoryIds(_filterOptions.categoryIds) : 
            null,
          familyId: null, // 如果需要家庭ID过滤，在这里添加
        );
        
        if (trendResponse.success && mounted && trendResponse.data != null) {
          final trendData = trendResponse.data;
          final List<double> incomeData = [];
          final List<double> expenseData = [];
          final List<String> labels = [];
          
          // 解析趋势数据
          if (trendData['data'] != null && trendData['data'] is List) {
            for (final point in trendData['data']) {
              // 添加收入数据
              incomeData.add((point['income'] ?? 0).toDouble());
              // 添加支出数据
              expenseData.add((point['expense'] ?? 0).toDouble());
              
              // 处理日期标签
              String label = '';
              if (point['date'] != null && point['date'].toString().isNotEmpty) {
                try {
                  final dateStr = point['date'].toString();
                  final date = DateTime.parse(dateStr);
                  label = DateFormat('MM/dd').format(date);
                } catch (e) {
                  // 如果日期解析失败，尝试使用label字段
                  label = point['label'] != null ? _formatLabelDate(point['label'].toString()) : '';
                }
              } else if (point['label'] != null) {
                // 使用label字段作为后备
                label = _formatLabelDate(point['label'].toString());
              }
              
              labels.add(label);
            }
            
            // 更新状态
            setState(() {
              _incomeData = incomeData;
              _expenseData = expenseData;
              _trendLabels = labels;
            });
            
            debugPrint('趋势图数据加载成功: ${_incomeData.length} 个数据点');
          }
        } else {
          // 趋势数据加载失败，使用默认数据
          debugPrint('趋势图数据加载失败: ${trendResponse.message}');
        }
      }
      
      // 处理交易分组数据
      if (groupsResponse.success && mounted && groupsResponse.data != null) {
        final groupsData = groupsResponse.data;
        
        // 解析交易分组数据
        if (groupsData is List) {
          final List<TransactionDateGroup> transGroups = [];
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          
          for (final groupData in groupsData) {
            // 获取日期和交易列表
            String? dateStr = groupData['date'];
            List? transactionsList = groupData['transactions'];
            
            // 修复总收入和总支出解析逻辑
            double totalIncome = 0;
            double totalExpense = 0;
            
            try {
              // 处理总收入
              final incomeValue = groupData['total_income'];
              if (incomeValue is num) {
                totalIncome = incomeValue.toDouble();
              } else if (incomeValue is String) {
                totalIncome = double.tryParse(incomeValue.replaceAll(',', '').trim()) ?? 0;
              }
              
              // 处理总支出
              final expenseValue = groupData['total_expense'];
              if (expenseValue is num) {
                totalExpense = expenseValue.toDouble();
              } else if (expenseValue is String) {
                totalExpense = double.tryParse(expenseValue.replaceAll(',', '').trim()) ?? 0;
              }
            } catch (e) {
              debugPrint('解析总收入/支出出错: $e, 原始数据: income=${groupData['total_income']}, expense=${groupData['total_expense']}');
              // 如果解析出错，尝试手动计算总额
              if (transactionsList != null) {
                for (final transaction in transactionsList) {
                  try {
                    final type = transaction['type'];
                    double amount = 0;
                    
                    final amountValue = transaction['amount'];
                    if (amountValue is num) {
                      amount = amountValue.toDouble();
                    } else if (amountValue is String) {
                      amount = double.tryParse(amountValue.replaceAll(',', '').trim()) ?? 0;
                    }
                    
                    if (type == 'income') {
                      totalIncome += amount;
                    } else {
                      totalExpense += amount;
                    }
                  } catch (e) {
                    // 忽略单个交易的解析错误
                  }
                }
              }
            }
            
            if (dateStr != null && transactionsList != null) {
              try {
                // 解析日期字符串，确保考虑时区影响
                final date = DateTime.parse(dateStr).toLocal();
                
                // 打印日期信息用于调试
                debugPrint('解析日期: 原始字符串=$dateStr, 解析后日期=${date.toString()}');
                
                final List<Transaction> transactions = [];
                
                // 解析每个交易
                for (final transaction in transactionsList) {
                  final transId = transaction['id']?.toString() ?? '';
                  final title = transaction['title'] ?? '未命名交易';
                  
                  // 解析商家或地点信息
                  String merchant = '';
                  if (transaction['merchant'] != null && transaction['merchant'].toString().isNotEmpty) {
                    merchant = transaction['merchant'].toString();
                  } else if (transaction['payee'] != null && transaction['payee'].toString().isNotEmpty) {
                    merchant = transaction['payee'].toString();
                  } else if (transaction['location'] != null && transaction['location'].toString().isNotEmpty) {
                    merchant = transaction['location'].toString();
                  } else if (transaction['place'] != null && transaction['place'].toString().isNotEmpty) {
                    merchant = transaction['place'].toString();
                  }
                  
                  // 组合标题，如果标题为空但有商家，则使用商家作为标题
                  String displayTitle = title;
                  if (title == '未命名交易' && merchant.isNotEmpty) {
                    displayTitle = merchant;
                  } else if (title != '未命名交易' && merchant.isNotEmpty && !title.contains(merchant)) {
                    displayTitle = '$title - $merchant';
                  }
                  
                  // 解析备注字段
                  String transactionDesc = '';
                  if (transaction['description'] != null && transaction['description'].toString().isNotEmpty) {
                    transactionDesc = transaction['description'].toString();
                  } else if (transaction['notes'] != null && transaction['notes'].toString().isNotEmpty) {
                    transactionDesc = transaction['notes'].toString();
                  } else if (transaction['remark'] != null && transaction['remark'].toString().isNotEmpty) {
                    transactionDesc = transaction['remark'].toString();
                  } else if (transaction['memo'] != null && transaction['memo'].toString().isNotEmpty) {
                    transactionDesc = transaction['memo'].toString();
                  }
                  
                  debugPrint('解析交易备注: $transactionDesc');
                  
                  // 修复金额解析逻辑
                  double amount = 0;
                  try {
                    // 处理多种可能的金额格式
                    final amountValue = transaction['amount'];
                    if (amountValue is num) {
                      amount = amountValue.toDouble();
                    } else if (amountValue is String) {
                      // 尝试将字符串转换为数字
                      amount = double.tryParse(amountValue.replaceAll(',', '').trim()) ?? 0;
                    } else if (amountValue is Map && amountValue.containsKey('value')) {
                      // 处理可能的嵌套结构
                      final value = amountValue['value'];
                      if (value is num) {
                        amount = value.toDouble();
                      } else if (value is String) {
                        amount = double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
                      }
                    }
                    
                    // 确保金额为正数，由交易类型决定符号
                    amount = amount.abs();
                  } catch (e) {
                    debugPrint('解析交易金额出错: $e, 原始数据: ${transaction['amount']}');
                    amount = 0; // 出错时默认为0
                  }
                  
                  final type = transaction['type'] == 'income' 
                      ? TransactionType.income 
                      : TransactionType.expense;
                  
                  // 获取分类信息
                  final category = transaction['category'] ?? {};
                  String categoryName = category['name'] ?? '未分类';
                  
                  // 打印完整的分类数据用于诊断
                  debugPrint('💾 【交易${transId}】完整分类数据: $category');
                  // 如果是对象，打印其所有键
                  if (category is Map) {
                    debugPrint('💾 【交易${transId}】分类字段键: ${category.keys.toList()}');
                  }
                  
                  // 解析图标代码和颜色
                  int iconId = -1;
                  IconData categoryIcon = Icons.category;
                  Color categoryColor = const Color(0xFF6B7280);
                  
                  // 直接从transaction对象获取icon_id，而不是从category对象中获取
                  try {
                    if (transaction['icon_id'] != null) {
                      final rawIconId = transaction['icon_id'].toString();
                      iconId = int.parse(rawIconId);
                      debugPrint('✅ 【交易${transId}】成功解析icon_id: $iconId, 原始数据: $rawIconId, 类型: ${transaction['icon_id'].runtimeType}');
                    } else {
                      debugPrint('⚠️ 【交易${transId}】transaction对象中没有icon_id字段');
                      
                      // 后备方案：尝试从其他可能的位置获取icon_id
                      if (category['icon_id'] != null) {
                        final rawIconId = category['icon_id'].toString();
                        iconId = int.parse(rawIconId);
                        debugPrint('ℹ️ 【交易${transId}】从category对象中找到icon_id: $iconId');
                      } else if (category['icon'] != null && category['icon'] is Map && category['icon']['id'] != null) {
                        final rawIconId = category['icon']['id'].toString();
                        iconId = int.parse(rawIconId);
                        debugPrint('ℹ️ 【交易${transId}】从category.icon.id中找到icon_id: $iconId');
                      } else {
                        debugPrint('❌ 【交易${transId}】无法找到有效的图标ID');
                      }
                    }
                  } catch (e) {
                    debugPrint('❌ 【交易${transId}】解析icon_id失败: $e');
                    iconId = -1;
                  }
                  
                  // 如果有图标ID，优先从缓存中获取
                  if (iconId > 0 && _iconCache.containsKey(iconId)) {
                    final iconModel = _iconCache[iconId]!;
                    categoryIcon = iconModel.icon;
                    categoryColor = iconModel.color;
                    // 使用图标名称作为分类名
                    categoryName = iconModel.name;
                    debugPrint('【交易${transId}】从缓存中获取图标: ID=$iconId, 名称=${iconModel.name}, 颜色=${iconModel.colorCode}');
                  } else if (iconId > 0) {
                    // 如果缓存中没有，保存iconId以便后续异步加载
                    debugPrint('【交易${transId}】图标ID=$iconId 将在后台加载');
                    
                    // 异步加载图标，避免阻塞UI
                    Future.microtask(() async {
                      final iconModel = await _getIconById(iconId);
                      if (iconModel != null && mounted) {
                        debugPrint('【交易${transId}】异步获取图标成功: ${iconModel.name}');
                        setState(() {
                          // 更新图标缓存已完成，UI将在下一次构建时使用新的图标
                        });
                      } else {
                        debugPrint('【交易${transId}】异步获取图标失败，iconModel为null');
                      }
                    });
                  } else {
                    debugPrint('【交易${transId}】无有效图标ID，将使用默认图标');
                  }
                  
                  // 获取成员信息
                  final member = transaction['member'] ?? {};
                  final memberId = member['id']?.toString() ?? '';
                  final memberName = member['name'] ?? '未知';
                  final memberRole = member['role'] ?? '';
                  
                  // 成员颜色（简化处理）
                  final memberColor = memberId == '1' 
                      ? const Color(0xFF4F46E5) 
                      : const Color(0xFF7C3AED);
                  
                  // 解析交易时间
                  DateTime transDate = date;
                  if (transaction['date'] != null && transaction['date'].toString().isNotEmpty) {
                    try {
                      // 尝试解析交易特定日期并转换为本地时间
                      transDate = DateTime.parse(transaction['date'].toString()).toLocal();
                      debugPrint('【交易${transId}】单独解析日期: ${transDate.toString()}');
                    } catch (e) {
                      debugPrint('【交易${transId}】解析日期失败，使用组日期: $e');
                    }
                  }
                  
                  // 从实际日期中提取时间，而不是使用默认值
                  TimeOfDay time = TimeOfDay(
                    hour: transDate.hour,
                    minute: transDate.minute
                  );
                  
                  // 创建交易对象并添加到列表
                  transactions.add(Transaction(
                    id: transId,
                    title: displayTitle,
                    description: transactionDesc,
                    merchant: merchant,
                    date: transDate,
                    time: time,
                    amount: amount,
                    type: type,
                    category: categoryName, // 使用更新后的categoryName（可能已被图标名称替换）
                    categoryIcon: categoryIcon,
                    categoryColor: categoryColor,
                    iconId: iconId > 0 ? iconId : null,
                    memberId: memberId,
                    memberName: memberName,
                    memberRole: memberRole,
                    memberColor: memberColor,
                  ));
                }
                
                // 判断是否为今天或昨天
                final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
                
                // 创建日期分组并添加到列表
                transGroups.add(TransactionDateGroup(
                  date: date,
                  transactions: transactions,
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                ));
                
                debugPrint('成功添加日期分组: ${date.toString()}, 交易数量: ${transactions.length}, 是否今天: $isToday, 是否昨天: $isYesterday');
              } catch (e) {
                debugPrint('解析交易分组数据出错: $e');
              }
            }
          }
          
          // 更新状态
          setState(() {
            if (loadMore) {
              // 加载更多时，添加新数据到现有数据后面
              _transactionGroups.addAll(transGroups);
              // 如果返回的数据少于页面大小或为空列表，说明没有更多数据了
              _hasMoreData = groupsData.isNotEmpty && groupsData.length >= _pageSize;
            } else {
              // 首次加载或刷新时，替换所有数据
              _transactionGroups.clear();
              _transactionGroups.addAll(transGroups);
              // 首次加载时，如果没有数据或数据少于页面大小，说明没有更多数据
              _hasMoreData = groupsData.isNotEmpty && groupsData.length >= _pageSize;
            }
          });
          
          debugPrint('交易分组数据加载成功: ${transGroups.length} 个分组, 总计: ${_transactionGroups.length} 个分组, 是否有更多数据: $_hasMoreData');
          
          // 如果是加载更多且没有加载到数据，标记没有更多数据
          if (loadMore && transGroups.isEmpty) {
            _hasMoreData = false;
            debugPrint('已加载全部数据，没有更多交易记录');
          }
        } else {
          // 返回数据不是列表格式
          setState(() {
            _hasMoreData = false;
          });
          debugPrint('交易分组数据格式错误，不是列表格式，标记为没有更多数据');
        }
      } else {
        // 加载失败或数据为null处理
        if (!loadMore) {
          // 当数据为null时，不再使用示例数据，只显示暂无数据
          if (groupsResponse.data == null) {
            setState(() {
              _transactionGroups.clear();
              _hasMoreData = false;
            });
            debugPrint('交易分组数据为null，清空现有数据并显示暂无数据');
          } else {
            debugPrint('交易分组数据加载失败: ${groupsResponse.message}');
            // 只有在数据加载失败但不为null时才使用示例数据
            _loadSampleTransactionGroups();
          }
        } else {
          // 加载更多时，标记没有更多数据
          setState(() {
            _hasMoreData = false;
          });
        }
      }
    } catch (e) {
      debugPrint('加载交易数据时发生异常: $e');
      
      // 只有在首次加载时且非null数据情况下才使用示例数据
      if (!loadMore) {
        _loadSampleTransactionGroups();
      }
      
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('数据加载出错: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (loadMore) {
            _isLoadingMoreTransactions = false;
          } else {
            _isLoadingTransactions = false;
          }
        });
        
        // 处理完所有交易数据后，异步加载图标
        if (_transactionGroups.isNotEmpty) {
          _loadIconsForTransactions();
        }
      }
    }
  }
  
  // 根据日期范围确定趋势数据的时间间隔
  String _getTrendInterval(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'day'; // 默认按天
    }
    
    final durationInDays = endDate.difference(startDate).inDays;
    
    if (durationInDays <= 31) {
      return 'day'; // 如果范围在31天内，按天显示
    } else if (durationInDays <= 180) {
      return 'week'; // 如果范围在180天内，按周显示
    } else {
      return 'month'; // 如果范围超过180天，按月显示
    }
  }
  
  // 加载示例交易数据组（用于API调用失败时保持UI完整）
  void _loadSampleTransactionGroups() {
    final now = DateTime.now();
    
    // 示例交易组1：今天
    final today = TransactionDateGroup(
      date: now,
      transactions: [
      Transaction(
        id: '1',
        title: '工资收入',
        description: '4月份工资',
          date: now,
          time: TimeOfDay.now(),
        amount: 11500,
        type: TransactionType.income,
        category: 'salary',
        categoryIcon: Icons.work,
        categoryColor: const Color(0xFF10B981),
        iconId: null,
        memberId: '1',
        memberName: '李明',
        memberRole: '爸爸',
        memberColor: const Color(0xFF4F46E5),
      ),
      Transaction(
        id: '2',
        title: '房贷还款',
        description: '4月房贷自动扣款',
        date: now,
        time: TimeOfDay.now(),
        amount: 4850,
        type: TransactionType.expense,
        category: 'housing',
        categoryIcon: Icons.home,
        categoryColor: const Color(0xFFEF4444),
        iconId: null,
        memberId: '1',
        memberName: '李明',
        memberRole: '爸爸',
        memberColor: const Color(0xFF4F46E5),
      ),
      Transaction(
        id: '3',
        title: '午餐',
        description: '华莱士外带',
        date: now,
        time: TimeOfDay.now(),
        amount: 85,
        type: TransactionType.expense,
        category: 'food',
        categoryIcon: Icons.restaurant,
        categoryColor: const Color(0xFFF59E0B),
        iconId: null,
        memberId: '2',
        memberName: '王芳',
        memberRole: '妈妈',
        memberColor: const Color(0xFF7C3AED),
        ),
      ],
      totalIncome: 11500,
      totalExpense: 4935,
    );
    
    // 示例交易组2：昨天
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final yesterdayGroup = TransactionDateGroup(
      date: yesterday,
      transactions: [
      Transaction(
        id: '4',
        title: '超市购物',
        description: '超市周采购',
        date: yesterday,
        time: TimeOfDay.now(),
        amount: 367,
        type: TransactionType.expense,
        category: 'shopping',
        categoryIcon: Icons.shopping_bag,
        categoryColor: const Color(0xFF8B5CF6),
        iconId: null,
        memberId: '2',
        memberName: '王芳',
        memberRole: '妈妈',
        memberColor: const Color(0xFF7C3AED),
      ),
      Transaction(
        id: '5',
        title: '加油',
        description: '中石化92号',
        date: yesterday,
        time: TimeOfDay.now(),
        amount: 330,
        type: TransactionType.expense,
        category: 'transport',
        categoryIcon: Icons.local_gas_station,
        categoryColor: const Color(0xFF3B82F6),
        iconId: null,
        memberId: '1',
        memberName: '李明',
        memberRole: '爸爸',
        memberColor: const Color(0xFF4F46E5),
      ),
      ],
      totalIncome: 0,
      totalExpense: 697,
    );
    
    // 使用示例数据更新状态
    setState(() {
      _transactionGroups.clear();
      _transactionGroups.addAll([today, yesterdayGroup]);
    });
  }
  
  // 加载家庭成员数据
  Future<void> _loadFamilyMembersData() async {
    try {
      final familyMemberService = FamilyMemberService(context: context);
      final response = await familyMemberService.getFamilyMembers();
      
      if (response.success && mounted) {
        setState(() {
          _familyMembers = response.data ?? [];
          
          // 为图表创建成员贡献数据
          _chartMembers = [
            chart_models.FamilyMember(
              name: '爸爸',
              role: '爸爸',
              income: 15000,
              expenses: 5334,
              budget: 6000,
              savingsRate: 0.4,
              budgetUsage: 0.89,
              incomeChange: 0.05,
              expensesChange: -0.02,
              color: const Color(0xFF4F46E5),
              icon: Icons.person,
              avatarBgColor: const Color(0xFFEEF2FF),
              incomeContribution: 0.45,
              expenseContribution: 0.35,
              mainConsumption: '住房',
            ),
            chart_models.FamilyMember(
              name: '妈妈',
              role: '妈妈',
              income: 12000,
              expenses: 5334,
              budget: 5500,
              savingsRate: 0.35,
              budgetUsage: 0.97,
              incomeChange: 0.03,
              expensesChange: 0.01,
              color: const Color(0xFF7C3AED),
              icon: Icons.person,
              avatarBgColor: const Color(0xFFF3E8FF),
              incomeContribution: 0.35,
              expenseContribution: 0.35,
              mainConsumption: '购物',
            ),
            chart_models.FamilyMember(
              name: '女儿',
              role: '女儿',
              income: 0,
              expenses: 3048,
              budget: 3000,
              savingsRate: 0.0,
              budgetUsage: 1.01,
              incomeChange: 0.0,
              expensesChange: 0.1,
              color: const Color(0xFFDB2777),
              icon: Icons.face,
              avatarBgColor: const Color(0xFFFCE7F3),
              incomeContribution: 0.0,
              expenseContribution: 0.2,
              mainConsumption: '教育',
            ),
            chart_models.FamilyMember(
              name: '儿子',
              role: '儿子',
              income: 0,
              expenses: 1524,
              budget: 2000,
              savingsRate: 0.0,
              budgetUsage: 0.76,
              incomeChange: 0.0,
              expensesChange: 0.05,
              color: const Color(0xFF3B82F6),
              icon: Icons.child_care,
              avatarBgColor: const Color(0xFFDBEAFE),
              incomeContribution: 0.0,
              expenseContribution: 0.1,
              mainConsumption: '娱乐',
            ),
          ];
        });
      }
    } catch (e) {
      debugPrint('加载家庭成员失败: $e');
    }
  }
  
  // 加载更多交易
  void _loadMoreTransactions() {
    debugPrint('加载更多交易记录，当前页码: $_currentPage');
    if (!_isLoadingMoreTransactions && _hasMoreData) {
      _currentPage++;
      _loadTransactionData(loadMore: true);
    }
  }

  // 根据筛选条件获取周期文本
  String _getPeriodText() {
    // 如果是自定义日期范围
    if (_filterOptions.period == FilterPeriod.custom && _filterOptions.customDateRange != null) {
      final start = _filterOptions.customDateRange!.start;
      final end = _filterOptions.customDateRange!.end;
      final DateFormat formatter = DateFormat('MM/dd');
      return '${formatter.format(start)} - ${formatter.format(end)}';
    }
    
    // 预设的时间范围
      switch (_filterOptions.period) {
        case FilterPeriod.last7Days:
        return '近7天';
        case FilterPeriod.last30Days:
        return '近30天';
        case FilterPeriod.last3Months:
        return '近3个月';
        case FilterPeriod.last6Months:
        return '近6个月';
        case FilterPeriod.last12Months:
        return '近12个月';
      case FilterPeriod.thisMonth:
        return '本月';
      case FilterPeriod.lastMonth:
        return '上月';
        case FilterPeriod.thisYear:
        return '今年';
        case FilterPeriod.lastYear:
        return '去年';
      default:
        return '近30天';
    }
  }

  // 格式化标签日期
  String _formatLabelDate(String labelDate) {
    try {
      // 尝试解析日期时间字符串
      final date = DateTime.parse(labelDate);
      return DateFormat('MM/dd').format(date);
    } catch (e) {
      // 如果解析失败，返回原始字符串
      return labelDate;
    }
  }

  // 辅助函数：将分类ID字符串列表转换为整数列表
  List<int> _parseFilterCategoryIds(List<String> ids) {
    return ids.map((id) {
      // 尝试将ID解析为整数
      final parsedId = int.tryParse(id);
      // 如果解析失败，返回0作为默认值（即全部分类）
      return parsedId ?? 0;
    }).toList();
  }

  // 根据图标ID获取图标数据，优先从缓存中获取
  Future<IconModel?> _getIconById(int iconId) async {
    debugPrint('🔍 开始获取图标: ID=$iconId');
    // 先检查缓存
    if (_iconCache.containsKey(iconId)) {
      debugPrint('✅ 图标ID=$iconId 已在缓存中找到');
      return _iconCache[iconId];
    }
    
    // 如果缓存中没有，从服务中获取
    try {
      debugPrint('🌐 调用IconService.getIconById($iconId)');
      final iconModel = await _iconService.getIconById(iconId, context: context);
      debugPrint('📦 IconService返回结果: ${iconModel != null ? "成功" : "null"}');
      
      if (iconModel != null) {
        // 添加到缓存
        _iconCache[iconId] = iconModel;
        debugPrint('✅ 成功获取图标ID=$iconId, 名称=${iconModel.name}, 图标代码=${iconModel.icon.codePoint}, 颜色=${iconModel.colorCode}');
      } else {
        debugPrint('❌ 图标ID=$iconId 获取失败，返回null');
      }
      return iconModel;
    } catch (e) {
      debugPrint('❌ 获取图标ID=$iconId 时发生异常: $e');
      return null;
    }
  }
  
  // 异步加载图标并更新交易数据
  Future<void> _loadIconsForTransactions() async {
    if (_transactionGroups.isEmpty) return;
    
    debugPrint('📊 开始加载交易图标数据...');
    int totalTransactions = 0;
    int transactionsWithIconId = 0;
    
    // 收集所有需要加载的图标ID
    final Set<int> iconIdsToLoad = {};
    
    // 遍历所有交易组和交易记录，收集图标ID
    for (final group in _transactionGroups) {
      for (final transaction in group.transactions) {
        totalTransactions++;
        // 检查Transaction对象是否有有效的iconId
        if (transaction.iconId != null && transaction.iconId! > 0) {
          transactionsWithIconId++;
          if (!_iconCache.containsKey(transaction.iconId)) {
            iconIdsToLoad.add(transaction.iconId!);
          }
        }
      }
    }
    
    debugPrint('📊 统计: 总交易数=$totalTransactions, 含图标ID的交易数=$transactionsWithIconId, 需加载的不同图标数=${iconIdsToLoad.length}');
    
    // 如果没有需要加载的图标，直接返回
    if (iconIdsToLoad.isEmpty) {
      debugPrint('💤 没有需要加载的图标');
      return;
    }
    
    debugPrint('🔄 需要加载 ${iconIdsToLoad.length} 个图标: $iconIdsToLoad');
    
    // 批量加载图标
    bool hasUpdatedIcons = false;
    int successCount = 0;
    int failCount = 0;
    
    for (final iconId in iconIdsToLoad) {
      try {
        debugPrint('🔄 正在加载图标ID=$iconId');
        final iconModel = await _iconService.getIconById(iconId, context: context);
        if (iconModel != null) {
          _iconCache[iconId] = iconModel;
          hasUpdatedIcons = true;
          successCount++;
          debugPrint('✅ 成功加载图标: ID=$iconId, 名称=${iconModel.name}, 颜色=${iconModel.colorCode}');
        } else {
          failCount++;
          debugPrint('❌ 警告: 图标ID=$iconId 加载失败，返回为null');
        }
      } catch (e) {
        failCount++;
        debugPrint('❌ 错误: 加载图标ID=$iconId 时发生异常: $e');
      }
    }
    
    debugPrint('📊 图标加载统计: 成功=$successCount, 失败=$failCount');
    
    // 如果成功加载了任何图标，更新Transaction对象并刷新UI
    if (hasUpdatedIcons && mounted) {
      debugPrint('🔄 开始更新交易对象的图标数据');
      int updatedTransactionsCount = 0;
      int skippedTransactionsCount = 0;
      
      setState(() {
        // 创建所有日期组的副本
        final updatedGroups = <TransactionDateGroup>[];
        
        // 遍历每个日期组
        for (final group in _transactionGroups) {
          final transactionList = <Transaction>[];
          
          // 更新每个交易的图标数据
          for (final transaction in group.transactions) {
            if (transaction.iconId != null && 
                transaction.iconId! > 0 && 
                _iconCache.containsKey(transaction.iconId)) {
              // 获取缓存中的图标数据
              final iconModel = _iconCache[transaction.iconId]!;
              
              // 创建新的Transaction对象，保留原始数据，更新图标数据
              transactionList.add(Transaction(
                id: transaction.id,
                title: transaction.title.isNotEmpty ? transaction.title : iconModel.name, // 如果标题为空，使用图标名称
                description: transaction.description,
                merchant: transaction.merchant,
                date: transaction.date,
                time: transaction.time,
                amount: transaction.amount,
                type: transaction.type,
                category: iconModel.name, // 使用图标名称作为分类名
                categoryIcon: iconModel.icon,
                categoryColor: iconModel.color,
                iconId: transaction.iconId,
                memberId: transaction.memberId,
                memberName: transaction.memberName,
                memberRole: transaction.memberRole,
                memberColor: transaction.memberColor,
              ));
              
              updatedTransactionsCount++;
              debugPrint('✅ 更新交易(${transaction.id})的图标: ID=${transaction.iconId}, 名称=${iconModel.name}, 图标=${iconModel.icon.codePoint}');
            } else {
              // 如果没有图标数据或加载失败，尝试使用原始category
              final String categoryName = transaction.category.isNotEmpty 
                  ? transaction.category 
                  : transaction.type == TransactionType.income ? '收入' : '支出';
                  
              transactionList.add(Transaction(
                id: transaction.id,
                title: transaction.title.isNotEmpty ? transaction.title : categoryName,
                description: transaction.description,
                merchant: transaction.merchant,
                date: transaction.date,
                time: transaction.time,
                amount: transaction.amount,
                type: transaction.type,
                category: categoryName,
                categoryIcon: transaction.categoryIcon,
                categoryColor: transaction.categoryColor,
                iconId: transaction.iconId,
                memberId: transaction.memberId,
                memberName: transaction.memberName,
                memberRole: transaction.memberRole,
                memberColor: transaction.memberColor,
              ));
              
              skippedTransactionsCount++;
              if (transaction.iconId != null && transaction.iconId! > 0) {
                debugPrint('⚠️ 无法更新交易(${transaction.id})的图标: ID=${transaction.iconId}, 原因: 图标未加载或加载失败');
              }
            }
          }
          
          // 创建新的日期组
          updatedGroups.add(TransactionDateGroup(
            date: group.date,
            transactions: transactionList,
            totalIncome: group.totalIncome,
            totalExpense: group.totalExpense,
          ));
        }
        
        // 清空现有组并添加更新后的组
        _transactionGroups.clear();
        _transactionGroups.addAll(updatedGroups);
      });
      
      debugPrint('📊 交易图标更新统计: 已更新=$updatedTransactionsCount, 已跳过=$skippedTransactionsCount');
      debugPrint('✅ 交易记录图标数据更新完成');
    } else if (!hasUpdatedIcons) {
      debugPrint('⚠️ 没有成功加载任何图标，交易记录将保持原样');
    }
  }

  // 删除交易记录
  Future<void> _handleDeleteTransaction(String transactionId) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // 调用服务删除交易记录
      final response = await _financeService.deleteTransaction(
        context: context,
        transactionId: transactionId,
      );
      
      // 关闭加载指示器
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        // 显示操作结果
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.success ? '删除成功' : '删除失败: ${response.message}'),
            backgroundColor: response.success ? Colors.green : Colors.red,
          ),
        );
        
        // 如果删除成功，重新加载数据
        if (response.success) {
          setState(() {
            _currentPage = 1;
            _transactionGroups.clear();
          });
          await _loadTransactionData();
        }
      }
    } catch (e) {
      // 关闭加载指示器
      if (mounted) Navigator.of(context).pop();
      
      // 显示错误信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 构建页面标题，包含成员信息
    final String pageTitle = _selectedMember != null 
        ? "${_selectedMember!.nickname.isNotEmpty ? _selectedMember!.nickname : _selectedMember!.name}的交易记录" 
        : "全部交易记录";
    
    return Scaffold(
      body: SafeArea(
        child: Column(
        children: [
            // 顶部导航与搜索区域 - 传入成员数据和回调
          TransactionHeader(
              selectedMember: _selectedMember,
              onMemberSelected: _onMemberSelected,
            ),
            
            // 筛选系统 - 传入初始筛选条件和回调
            TransactionFilters(
              initialFilters: _filterOptions,
              onFilterChanged: _onFilterChanged,
            ),
            
            // 主内容区域，使用Expanded确保占满剩余空间
          Expanded(
              child: _isLoadingInitialMember 
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadTransactionData,
            child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            // 页面标题，显示当前筛选的成员
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                pageTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // 交易类型选项卡
                    TransactionTabs(
                              selectedTab: _selectedTab,
                      onTabSelected: _onTabSelected,
                    ),
                            
                    const SizedBox(height: 16),
                    
                            // 交易统计摘要
                    TransactionSummary(
                              transactionCount: _transactionCount,
                      totalIncome: _totalIncome,
                      totalExpense: _totalExpense,
                    ),
                            
                    const SizedBox(height: 16),
                    
                            // 交易趋势图表
                    TransactionTrendChart(
                      incomeData: _incomeData,
                      expenseData: _expenseData,
                      labels: _trendLabels,
                      periodText: _getPeriodText(),
                    ),
                            
                    const SizedBox(height: 16),
                    
                            // 交易列表
                            if (_isLoadingTransactions)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_transactionGroups.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(32),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '暂无交易记录',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                    TransactionList(
                                transactionGroups: _transactionGroups,
                      onLoadMore: _loadMoreTransactions,
                      isLoadingMore: _isLoadingMoreTransactions,
                      hasMoreData: _hasMoreData,
                      onDeleteTransaction: _handleDeleteTransaction,
                    ),
                  ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
