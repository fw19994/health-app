/// 通用的 API 响应模型
class ApiResponse<T> {
  final bool success;      // 操作是否成功
  final String? message;   // 消息文本
  final T? data;           // 泛型数据
  final int code;          // API 返回的状态码或业务码

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.code,
  });

  /// 从 JSON 数据创建 ApiResponse 实例
  /// 
  /// [json] 是 API 返回的 JSON 对象
  /// [fromJsonT] 是一个函数，用于将 data 部分的 JSON 转换为具体的泛型类型 T
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    // 优先使用外层的 success 和 message (如果后端在固定层级返回)
    // 否则尝试从 data 内部获取 (兼容某些后端设计)
    bool successStatus = json['success'] ?? (json['code'] == 0 || json['code'] == 200 || json['code'] == 201); // 根据 code 判断成功状态
    String? msg = json['message'] ?? json['msg'];
    int responseCode = json['code'] ?? -1; // 默认错误码

    T? data;
    if (json.containsKey('data') && json['data'] != null && fromJsonT != null) {
      // 如果有 data 字段且不为 null，并且提供了转换函数
      try {
        data = fromJsonT(json['data']);
      } catch (e) {
        print("Error parsing data in ApiResponse.fromJson: $e");
        // 如果数据解析失败，可以根据需要设置 success 为 false 或保留原状
        // successStatus = false;
        // msg = msg ?? "数据解析失败"; 
      }
    } else if (fromJsonT == null && json.containsKey('data')) {
       // 如果不需要转换 data (例如 T 是 void 或 dynamic)
       data = json['data'] as T?;
    } else if (fromJsonT != null && !json.containsKey('data')){
        // 如果期望有 data 但 json 中没有 data 字段
        print("Warning: 'data' key not found in ApiResponse.fromJson, but fromJsonT was provided.");
    }
    

    return ApiResponse<T>(
      success: successStatus,
      message: msg,
      data: data,
      code: responseCode,
    );
  }
} 