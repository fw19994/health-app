class Validators {
  /// 验证中国大陆手机号
  /// 
  /// 规则:
  /// - 必须为11位数字
  /// - 第一位必须是1
  /// - 第二位可以是3-9中的任意数字
  static bool isValidChinesePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return false;
    }
    
    // 验证长度
    if (phone.length != 11) {
      return false;
    }
    
    // 正则表达式验证格式
    final RegExp phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegExp.hasMatch(phone);
  }
  
  /// 获取手机号验证错误消息
  static String? getPhoneNumberErrorMessage(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '请输入手机号';
    }
    
    if (phone.length != 11) {
      return '手机号必须为11位';
    }
    
    if (!phone.startsWith('1')) {
      return '手机号必须以1开头';
    }
    
    if (!isValidChinesePhoneNumber(phone)) {
      return '请输入有效的中国大陆手机号';
    }
    
    return null; // 没有错误
  }
}
