import 'package:flutter/material.dart';
import '../../../models/family_member_model.dart';
import '../../../services/user_service.dart';
import 'common_components.dart' as components;

class FindUserForm extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController nicknameController;
  final TextEditingController descriptionController;
  final String selectedRelation;
  final List<bool> permissions;
  final bool isSearching;
  final bool? userFound;
  final Map<String, dynamic>? foundUserData;
  final Function(String?) onRelationChanged;
  final Function(int, bool?) onPermissionChanged;
  final Function() onSearchUser;
  final Function() onAddUser;
  final Function()? onSwitchToVirtual;

  const FindUserForm({
    Key? key,
    required this.phoneController,
    required this.nicknameController,
    required this.descriptionController,
    required this.selectedRelation,
    required this.permissions,
    required this.isSearching,
    required this.userFound,
    required this.foundUserData,
    required this.onRelationChanged,
    required this.onPermissionChanged,
    required this.onSearchUser,
    required this.onAddUser,
    this.onSwitchToVirtual,
  }) : super(key: key);

  @override
  State<FindUserForm> createState() => _FindUserFormState();
}

class _FindUserFormState extends State<FindUserForm> {
  @override
  Widget build(BuildContext context) {
    if (widget.userFound == true) {
      return _buildUserFoundState();
    } else if (widget.userFound == false) {
      return _buildUserNotFoundState();
    } else {
      return _buildSearchForm();
    }
  }
  
  // 搜索表单
  Widget _buildSearchForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索手机号输入框和搜索按钮合并为一行
        const Text(
          '手机号码',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: TextField(
                    controller: widget.phoneController,
                    decoration: const InputDecoration(
                      hintText: '请输入用户手机号',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xFFA0AEC0),
                        fontSize: 14,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.isSearching ? null : widget.onSearchUser,
                icon: widget.isSearching 
                    ? const SizedBox(
                        width: 20, 
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                        ),
                      )
                    : const Icon(
                        Icons.search,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
              ),
            ],
          ),
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
      ],
    );
  }
  
  // 已找到用户状态
  Widget _buildUserFoundState() {
    if (widget.foundUserData == null) {
      return const SizedBox.shrink();
    }
    
    final userData = widget.foundUserData!;
    final name = userData['nickname'] ?? userData['name'] ?? '';
    final phone = userData['phone'] ?? '';
    final avatarUrl = userData['avatar'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示找到的用户
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              // 用户头像
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '手机号：$phone',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 状态指示器
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '已找到',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // 角色选择
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
        
        // 个人描述
        components.FormField(
          label: '个人描述 (可选)',
          controller: widget.descriptionController,
          placeholder: '简短描述，如"大学生"',
          isRequired: false,
        ),
        const SizedBox(height: 16),
        
        // 操作按钮
        components.ActionButtons(
          onCancel: () {
            // 清除搜索结果
            widget.phoneController.clear();
          },
          onSubmit: widget.onAddUser,
          userFound: widget.userFound,
        ),
      ],
    );
  }

  // 未找到用户状态
  Widget _buildUserNotFoundState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索手机号输入框和搜索按钮合并为一行
        const Text(
          '手机号码',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: TextField(
                    controller: widget.phoneController,
                    decoration: const InputDecoration(
                      hintText: '请输入用户手机号',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xFFA0AEC0),
                        fontSize: 14,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.isSearching ? null : widget.onSearchUser,
                icon: widget.isSearching 
                    ? const SizedBox(
                        width: 20, 
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                        ),
                      )
                    : const Icon(
                        Icons.search,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 未找到用户提示
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(
                  Icons.person_off,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '未找到该用户，请检查手机号是否正确',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
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
      ],
    );
  }
} 