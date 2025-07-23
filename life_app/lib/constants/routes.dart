class Routes {
  // 主屏幕
  static const home = '/home';
  
  // 登录
  static const login = '/login';
  
  // 个人资料
  static const profile = '/profile';
  static const editBasicInfo = '/profile/edit-basic-info';
  static const editHealthInfo = '/profile/edit-health-info';
  
  // 家庭成员
  static const familyMembers = '/family-members';
  static const addFamilyMember = '/family-members/add';
  static const editFamilyMember = '/family-members/edit';
  static const memberDetail = '/family-members/detail';
  
  // 财务相关
  static const memberFinances = '/member-finances';
  static const budgetSettings = '/budget-settings';
  static const expenseTracking = '/expense-tracking';
  static const transactionHistory = '/transaction-history';
  static const familyFinance = '/family-finance';
  static const savingsGoals = '/savings-goals';
  
  // 计划相关
  static const String dailyPlan = '/plan/daily';
  static const String monthlyPlan = '/plan/monthly';
  static const String addPlan = '/plan/add';
  static const String editPlan = '/plan/edit';
  static const String addEditPlan = '/plan/add-edit';
  static const String planSettings = '/plan/settings';
  static const String planAnalysis = '/plan/analysis';
  
  // 专项计划相关
  static const String specialProjects = '/special-projects';
  static const String specialProjectsList = '/special-projects/list';
  static const String specialProjectDetail = '/special-projects/detail';
  static const String addSpecialProject = '/special-projects/add';
  static const String editSpecialProject = '/special-projects/edit';
  
  // 其他
  static const assistant = '/assistant';
}
