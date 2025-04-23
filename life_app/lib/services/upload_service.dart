import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/api_constants.dart';
import '../models/response_model.dart';

// 有条件导入dart:io，Web平台不使用该库
import 'dart:io' if (dart.library.html) 'package:flutter/foundation.dart';

/// 上传服务
class UploadService {
  final BuildContext? context;
  
  UploadService({this.context});
  
  /// 获取访问令牌
  Future<String?> _getAccessToken() async {
    if (context != null) {
      try {
        final authService = Provider.of<AuthService>(context!, listen: false);
        return authService.tokens?.accessToken;
      } catch (e) {
        if (kDebugMode) {
          print('获取令牌失败: $e');
        }
      }
    }
    return null;
  }

  /// 上传图片，返回图片URL
  /// [imageFile] 可以是XFile类型
  /// [directory] 可选参数，指定存储目录，默认为"common"
  Future<ResponseModel> uploadImage(dynamic imageFile, {String directory = 'common'}) async {
    try {
      // 获取访问令牌
      final token = await _getAccessToken();
      if (token == null) {
        return ResponseModel(
          code: -1,
          message: '未授权，请先登录',
          data: null,
        );
      }
      
      // 创建multipart请求
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/api/v1/upload/image'),
      );
      
      // 添加授权头
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      // 添加可选的目录参数
      request.fields['directory'] = directory;
      
      // 根据平台和文件类型处理
      if (imageFile is XFile) {
        if (kIsWeb) {
          // Web平台处理
          final bytes = await imageFile.readAsBytes();
          final fileName = imageFile.name;
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: fileName,
              contentType: MediaType.parse('image/${fileName.split('.').last}'),
            ),
          );
        } else {
          // 移动平台处理
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              imageFile.path,
            ),
          );
        }
      } else if (!kIsWeb && imageFile is XFile) {
        // 移动平台处理
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      } else {
        return ResponseModel(
          code: -1,
          message: '不支持的文件类型',
          data: null,
        );
      }
      
      // 发送请求
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 0) {
        // 上传成功，返回图片URL
        return ResponseModel(
          code: 0,
          message: data['message'] ?? '图片上传成功',
          data: data['data'],
        );
      } else {
        return ResponseModel(
          code: data['code'] ?? -1,
          message: data['message'] ?? '图片上传失败',
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('图片上传失败: $e');
      }
      return ResponseModel(
        code: -1,
        message: '图片上传失败: $e',
        data: null,
      );
    }
  }
  
  /// 从相册选择图片并上传
  /// [directory] 可选参数，指定存储目录
  Future<ResponseModel> pickAndUploadImageFromGallery({String directory = 'common'}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85, // 压缩质量，减小文件大小
      );
      
      if (image != null) {
        return await uploadImage(image, directory: directory);
      } else {
        return ResponseModel(
          code: -1,
          message: '未选择图片',
          data: null,
        );
      }
    } catch (e) {
      return ResponseModel(
        code: -1,
        message: '选择图片失败: $e',
        data: null,
      );
    }
  }
  
  /// 使用相机拍照并上传
  /// [directory] 可选参数，指定存储目录
  Future<ResponseModel> pickAndUploadImageFromCamera({String directory = 'common'}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85, // 压缩质量，减小文件大小
      );
      
      if (photo != null) {
        return await uploadImage(photo, directory: directory);
      } else {
        return ResponseModel(
          code: -1,
          message: '未拍摄照片',
          data: null,
        );
      }
    } catch (e) {
      return ResponseModel(
        code: -1,
        message: '拍照失败: $e',
        data: null,
      );
    }
  }
} 