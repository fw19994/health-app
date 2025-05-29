import 'package:flutter/material.dart';

// 交易类型筛选枚举
enum TransactionFilter {
  all,      // 全部交易
  income,   // 仅收入
  expense,  // 仅支出
}

// 时间段筛选枚举
enum FilterPeriod {
  last7Days,    // 过去7天
  last30Days,   // 过去30天
  last3Months,  // 过去3个月
  last6Months,  // 过去6个月
  last12Months, // 过去12个月
  thisMonth,    // 本月
  lastMonth,    // 上月
  thisYear,     // 今年
  lastYear,     // 去年
  custom,       // 自定义时间范围
}

// 筛选选项数据模型
class FilterOptions {
  // 成员ID
  final String? memberId;
  
  // 交易类型
  final TransactionFilter transactionType;
  
  // 分类ID（单选，保留向后兼容）
  final String? categoryId;
  
  // 分类ID列表（多选）
  final List<String> categoryIds;
  
  // 时间段
  final FilterPeriod period;
  
  // 自定义日期范围（当period为custom时有效）
  final DateTimeRange? customDateRange;
  
  const FilterOptions({
    this.memberId,
    this.transactionType = TransactionFilter.all,
    this.categoryId,
    this.categoryIds = const [],
    this.period = FilterPeriod.thisMonth,
    this.customDateRange,
  });
  
  // 创建筛选选项的副本，并更新特定字段
  FilterOptions copyWith({
    String? memberId,
    TransactionFilter? transactionType,
    String? categoryId,
    List<String>? categoryIds,
    FilterPeriod? period,
    DateTimeRange? customDateRange,
  }) {
    return FilterOptions(
      memberId: memberId ?? this.memberId,
      transactionType: transactionType ?? this.transactionType,
      categoryId: categoryId ?? this.categoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      period: period ?? this.period,
      customDateRange: customDateRange ?? this.customDateRange,
    );
  }
  
  // 清除所有筛选条件，返回默认状态
  FilterOptions clearAll() {
    return const FilterOptions(
      memberId: null,
      transactionType: TransactionFilter.all,
      categoryId: null,
      categoryIds: [],
      period: FilterPeriod.thisMonth,
      customDateRange: null,
    );
  }
  
  // 获取时间段的文本描述
  String getPeriodText() {
    switch (period) {
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
      case FilterPeriod.custom:
        if (customDateRange != null) {
          return '自定义';
        }
        return '近7天';
    }
  }
  
  // 重写相等性比较操作符
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterOptions) return false;
    
    // 比较categoryIds列表
    bool categoryIdsEqual = true;
    if (categoryIds.length != other.categoryIds.length) {
      categoryIdsEqual = false;
    } else {
      for (int i = 0; i < categoryIds.length; i++) {
        if (!other.categoryIds.contains(categoryIds[i])) {
          categoryIdsEqual = false;
          break;
        }
      }
    }
    
    return memberId == other.memberId &&
           transactionType == other.transactionType &&
           categoryId == other.categoryId &&
           categoryIdsEqual &&
           period == other.period &&
           (_compareDateRanges(customDateRange, other.customDateRange));
  }
  
  // 比较两个DateTimeRange是否相等
  bool _compareDateRanges(DateTimeRange? a, DateTimeRange? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    
    return a.start == b.start && a.end == b.end;
  }

  @override
  int get hashCode => 
      memberId.hashCode ^ 
      transactionType.hashCode ^ 
      categoryId.hashCode ^ 
      categoryIds.fold(0, (prev, element) => prev ^ element.hashCode) ^
      period.hashCode ^ 
      (customDateRange?.start.hashCode ?? 0) ^ 
      (customDateRange?.end.hashCode ?? 0);
      
  // 转换为JSON表示
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'transactionType': transactionType.toString(),
      'categoryId': categoryId,
      'categoryIds': categoryIds,
      'period': period.toString(),
      'customDateRange': customDateRange != null 
          ? {
              'start': customDateRange!.start.toIso8601String(),
              'end': customDateRange!.end.toIso8601String(),
            } 
          : null,
    };
  }
}
