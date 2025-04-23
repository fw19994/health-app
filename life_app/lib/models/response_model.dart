/// 统一API响应模型
class ResponseModel {
  final int code;
  final String message;
  final dynamic data;

  ResponseModel({
    required this.code,
    required this.message,
    this.data,
  });

  /// 判断是否成功
  bool get isSuccess => code == 0;

  /// 从JSON创建
  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      code: json['code'] ?? -1,
      message: json['message'] ?? '未知错误',
      data: json['data'],
    );
  }
}
