enum Environment { local, production }

class ApiConstants {
  static Environment _environment = Environment.production;
  
  // 设置当前环境
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  // 获取当前环境
  static Environment getEnvironment() {
    return _environment;
  }
  
  // 根据环境获取基础URL
  static String get baseUrl {
    switch (_environment) {
      case Environment.local:
        return 'http://127.0.0.1:8082';
      case Environment.production:
        // 部署到线上后改为你的 API 根地址，勿将内网或他人域名提交到公开仓库
        return 'https://api.example.com';
    }
  }
  
  // API路径
  static const String login = '/api/v1/auth/login/sms';
  static const String register = '/api/v1/auth/register';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String sendSMSCode = '/api/v1/auth/sms/send';
  
  // 计划管理API - 根据后端路由修正
  static const String getPlans = '/api/v1/plan/daily'; // 获取日计划
  static const String getMonthlyPlans = '/api/v1/plan/monthly'; // 获取月计划
  static const String createPlan = '/api/v1/plan'; // 创建计划
  static const String updatePlan = '/api/v1/plan'; // 后接 /{id}
  static const String deletePlan = '/api/v1/plan'; // 后接 /{id}
  static const String completePlan = '/api/v1/plan'; // 后接 /{id}/complete
  static const String cancelPlan = '/api/v1/plan'; // 后接 /{id}/cancel
  
  // 专项计划API
  static const String getSpecialProjects = '/api/v1/plan/project/user'; // 获取用户的专项计划
  static const String createSpecialProject = '/api/v1/plan/project'; // 创建专项计划
  static const String updateSpecialProject = '/api/v1/plan/project'; // 后接 /{id}
  static const String deleteSpecialProject = '/api/v1/plan/project'; // 后接 /{id}
  static const String getSpecialProjectDetail = '/api/v1/plan/project'; // 后接 /{id}
  static const String updateSpecialProjectStatus = '/api/v1/plan/project'; // 后接 /{id}/status
  
  // 专项计划阶段API
  static const String getProjectPhases = '/api/v1/plan/project/phase/project'; // 后接 /{project_id}
  static const String createPhase = '/api/v1/plan/project/phase'; // 创建阶段
  static const String updatePhase = '/api/v1/plan/project/phase'; // 后接 /{id}
  static const String deletePhase = '/api/v1/plan/project/phase'; // 后接 /{id}
  static const String reorderPhases = '/api/v1/plan/project/phase/project'; // 后接 /{project_id}/reorder
  static const String getPlansByPhaseID = '/api/v1/plan/project/phase'; // 后接 /{id}/plans
  
  // 超时时间
  static const int connectTimeout = 10000; // 10秒
  static const int receiveTimeout = 5000;  // 5秒
}
