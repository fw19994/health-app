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
        return 'https://api.shoppingfw.cn';
      case Environment.production:
        return 'https://api.shoppingfw.cn';
    }
  }
  
  // API路径
  static const String login = '/api/v1/auth/login/sms';
  static const String register = '/api/v1/auth/register';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String sendSMSCode = '/api/v1/auth/sms/send';
  
  // 超时时间
  static const int connectTimeout = 10000; // 10秒
  static const int receiveTimeout = 5000;  // 5秒
}
