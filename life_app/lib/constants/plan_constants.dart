/// 计划模块相关的常量定义
class PlanConstants {
  // 路由路径
  static const String dailyPlan = '/daily_plan';
  static const String monthlyPlan = '/monthly_plan';
  static const String addEditPlan = '/add_edit_plan';
  static const String planSettings = '/plan_settings';
  static const String planAnalysis = '/plan_analysis';
  
  // 计划类别
  static const Map<String, Map<String, dynamic>> categories = {
    'work': {
      'name': '工作',
      'iconColor': 0xFF2563EB,
      'iconBackground': 0xFFDBEAFE,
    },
    'personal': {
      'name': '个人',
      'iconColor': 0xFFD97706,
      'iconBackground': 0xFFFEF3C7,
    },
    'health': {
      'name': '健康',
      'iconColor': 0xFF059669,
      'iconBackground': 0xFFD1FAE5,
    },
    'family': {
      'name': '家庭',
      'iconColor': 0xFF7C3AED,
      'iconBackground': 0xFFEDE9FE,
    },
    'study': {
      'name': '学习',
      'iconColor': 0xFFC026D3,
      'iconBackground': 0xFFFAE8FF,
    },
    'finance': {
      'name': '财务',
      'iconColor': 0xFF0891B2,
      'iconBackground': 0xFFCFFAFE,
    },
    'social': {
      'name': '社交',
      'iconColor': 0xFFDC2626,
      'iconBackground': 0xFFFEE2E2,
    },
  };
  
  // 兼容旧代码的计划类别列表格式
  static List<Map<String, dynamic>> get planCategories {
    return categories.entries.map((entry) => {
      'id': entry.key,
      'name': entry.value['name'],
      'color': entry.value['iconColor'],
    }).toList();
  }
  
  // 重复类型选项
  static const Map<String, String> recurrenceOptions = {
    'once': '一次性',
    'daily': '每天',
    'weekly': '每周',
    'monthly': '每月',
    'weekdays': '工作日',
    'weekends': '周末',
    'yearly': '每年',
    'custom': '自定义',
  };
  
  // 兼容旧代码的重复类型列表格式
  static List<Map<String, dynamic>> get recurrenceTypes {
    return recurrenceOptions.entries.map((entry) => {
      'id': entry.key,
      'name': entry.value,
    }).toList();
  }
  
  // 提醒时间选项
  static const Map<int, String> reminderOptions = {
    0: '不提醒',
    5: '提前5分钟',
    10: '提前10分钟',
    15: '提前15分钟',
    30: '提前30分钟',
    60: '提前1小时',
    120: '提前2小时',
    1440: '提前1天',
  };
  
  // 过滤选项
  static const List<String> filterOptions = ['全部', '今天', '已完成', '置顶'];
  
  // 计划状态
  static const String statusCompleted = 'completed';
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusOverdue = 'overdue';
} 