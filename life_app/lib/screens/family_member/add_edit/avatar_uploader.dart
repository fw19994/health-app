import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../services/upload_service.dart';

class AvatarUploader extends StatefulWidget {
  final XFile? selectedAvatar;
  final String? avatarUrl;
  final bool isUploading;
  final Function(XFile?) onAvatarSelected;
  final Function(String) onUrlReceived;
  final Function(bool) onUploadingChanged;
  
  const AvatarUploader({
    Key? key,
    this.selectedAvatar,
    this.avatarUrl,
    required this.isUploading,
    required this.onAvatarSelected,
    required this.onUrlReceived,
    required this.onUploadingChanged,
  }) : super(key: key);

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF10B981),
          width: 2,
        ),
        image: _getAvatarDecoration(),
      ),
      child: widget.isUploading
          ? _buildUploadingIndicator()
          : _buildAvatarControls(context),
    );
  }
  
  // 获取头像的背景装饰
  DecorationImage? _getAvatarDecoration() {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      // 有网络图片
      return DecorationImage(
        image: NetworkImage(widget.avatarUrl!),
        fit: BoxFit.cover,
      );
    } else if (widget.selectedAvatar != null) {
      // 有本地选择的图片
      if (kIsWeb) {
        // Web平台使用network image
        return DecorationImage(
          image: NetworkImage(widget.selectedAvatar!.path),
          fit: BoxFit.cover,
        );
      } else {
        // 移动平台使用文件
        return DecorationImage(
          image: FileImage(File(widget.selectedAvatar!.path)),
          fit: BoxFit.cover,
        );
      }
    }
    
    return null;
  }
  
  // 构建上传中指示器
  Widget _buildUploadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF10B981),
        strokeWidth: 2.0,
      ),
    );
  }
  
  // 构建头像控制区
  Widget _buildAvatarControls(BuildContext context) {
    // 如果已有头像，显示编辑按钮；如果没有，显示上传按钮
    final bool hasAvatar = (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) || widget.selectedAvatar != null;
    
    return Stack(
      children: [
        if (!hasAvatar)
          const Center(
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
          ),
          
        // 右下角添加/编辑按钮
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => _pickImage(context),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasAvatar ? Icons.edit : Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // 选择图片
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        widget.onAvatarSelected(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }
  
  // 上传头像到服务器
  Future<void> uploadAvatar(BuildContext context, XFile? imageFile) async {
    if (imageFile == null) return;
    
    widget.onUploadingChanged(true);
    
    try {
      // 使用UploadService上传图片到family目录
      final uploadService = UploadService(context: context);
      final response = await uploadService.uploadImage(imageFile, directory: 'family');
      
      if (response.code == 0 && response.data != null) {
        // 成功获取图片URL
        widget.onUrlReceived(response.data['url']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像上传失败: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('头像上传失败: $e')),
      );
    } finally {
      widget.onUploadingChanged(false);
    }
  }
} 