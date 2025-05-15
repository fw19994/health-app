import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'common_components.dart' as components;
import 'avatar_uploader.dart';
import '../../../models/family_member_model.dart';

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
  final FamilyMember? memberToEdit;
  
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
    this.memberToEdit,
  }) : super(key: key);
  
  @override
  State<CreateVirtualForm> createState() => _CreateVirtualFormState();
}

class _CreateVirtualFormState extends State<CreateVirtualForm> {
  // 判断是否为虚拟成员
  bool get _isVirtualMember {
    // 非编辑模式下默认是虚拟成员
    if (!widget.isEditing) return true;
    
    // 编辑模式下，根据memberToEdit的userId判断
    if (widget.memberToEdit == null) return false;
    
    // userId为null或者0表示是虚拟成员
    return widget.memberToEdit!.userId == null || widget.memberToEdit!.userId == 0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像上传
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: AvatarUploader(
            selectedAvatar: widget.selectedAvatar,
            avatarUrl: widget.avatarUrl,
            isUploading: widget.isUploading,
            onAvatarSelected: widget.onAvatarSelected,
            onUrlReceived: widget.onAvatarUrlReceived,
            onUploadingChanged: widget.onUploadingChanged,
          ),
        ),
        ),
        
        // 虚拟成员提示 - 只在非编辑模式下或编辑虚拟成员时显示
        if (_isVirtualMember && !widget.isEditing) 
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFBD38D), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '虚拟成员不会自动接收邀请通知',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // 分隔线
        Divider(color: Colors.grey.shade200, height: 32),
        
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
        
        // 性别和家庭关系放在同一行
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // 性别字段
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        const Text(
                    '性别 (可选)',
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
                ],
              ),
            ),
            const SizedBox(width: 16),
        
        // 家庭关系
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          ],
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
        const SizedBox(height: 24),
        
        // 虚拟成员标记 - 仅当是虚拟成员时显示
        if (_isVirtualMember)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFBD38D), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDBA74),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '虚拟成员',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '此成员为虚拟用户，将无法自行登录使用',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF9A3412),
                        height: 1.3,
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