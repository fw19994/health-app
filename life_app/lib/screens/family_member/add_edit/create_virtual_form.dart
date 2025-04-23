import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'common_components.dart' as components;
import 'avatar_uploader.dart';

class CreateVirtualForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController; 
  final TextEditingController descriptionController;
  final TextEditingController nicknameController;
  final String selectedRelation;
  final String selectedGender;
  final List<bool> permissions;
  final XFile? selectedAvatar;
  final String? avatarUrl;
  final bool isUploading;
  final bool isEditing;
  final Function(String?) onRelationChanged;
  final Function(String?) onGenderChanged;
  final Function(int, bool?) onPermissionChanged;
  final Function(XFile?) onAvatarSelected;
  final Function(String) onAvatarUrlReceived;
  final Function(bool) onUploadingChanged;
  final Function() onSubmitForm;
  final Function() onCancel;
  
  const CreateVirtualForm({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.descriptionController,
    required this.nicknameController,
    required this.selectedRelation,
    required this.selectedGender,
    required this.permissions,
    required this.selectedAvatar,
    required this.avatarUrl,
    required this.isUploading,
    required this.isEditing,
    required this.onRelationChanged,
    required this.onGenderChanged,
    required this.onPermissionChanged,
    required this.onAvatarSelected,
    required this.onAvatarUrlReceived,
    required this.onUploadingChanged,
    required this.onSubmitForm,
    required this.onCancel,
  }) : super(key: key);
  
  @override
  State<CreateVirtualForm> createState() => _CreateVirtualFormState();
}

class _CreateVirtualFormState extends State<CreateVirtualForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像上传
        Center(
          child: AvatarUploader(
            selectedAvatar: widget.selectedAvatar,
            avatarUrl: widget.avatarUrl,
            isUploading: widget.isUploading,
            onAvatarSelected: widget.onAvatarSelected,
            onUrlReceived: widget.onAvatarUrlReceived,
            onUploadingChanged: widget.onUploadingChanged,
          ),
        ),
        const SizedBox(height: 24),
        
        // 表单字段
        components.FormField(
          label: '姓名',
          controller: widget.nameController,
          placeholder: '输入成员姓名',
        ),
        const SizedBox(height: 16),
        
        components.FormField(
          label: '手机号码 (可选)',
          controller: widget.phoneController,
          placeholder: '输入联系电话',
          isRequired: false,
        ),
        const SizedBox(height: 16),
        
        // 性别字段
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        components.GenderDropdown(
          selectedGender: widget.selectedGender,
          onChanged: widget.onGenderChanged,
        ),
        const SizedBox(height: 16),
        
        // 家庭关系
        const Text(
          '家庭关系',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        components.RelationDropdown(
          selectedRelation: widget.selectedRelation,
          onChanged: widget.onRelationChanged,
        ),
        const SizedBox(height: 16),
        
        // 家庭称呼
        components.FormField(
          label: '家庭称呼 (可选)',
          controller: widget.nicknameController,
          placeholder: '如：老爸、小明...',
          isRequired: false,
        ),
        const SizedBox(height: 16),
        
        components.FormField(
          label: '描述 (可选)',
          controller: widget.descriptionController,
          placeholder: '简短描述，如"大学生"',
          isRequired: false,
        ),
        const SizedBox(height: 16),
        
        // 虚拟成员标记
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '虚拟成员',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '此成员为虚拟用户，将无法自行登录使用',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // 操作按钮
        components.ActionButtons(
          onCancel: widget.onCancel,
          onSubmit: widget.onSubmitForm,
          isEditing: widget.isEditing,
          currentTab: 1,
        ),
      ],
    );
  }
} 