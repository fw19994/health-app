import 'package:flutter/material.dart';

class CreateVirtualMemberForm extends StatefulWidget {
  final int ownerId;
  final Function(Map<String, dynamic>) onMemberCreated;

  const CreateVirtualMemberForm({
    super.key,
    required this.ownerId,
    required this.onMemberCreated,
  });

  @override
  State<CreateVirtualMemberForm> createState() => _CreateVirtualMemberFormState();
}

class _CreateVirtualMemberFormState extends State<CreateVirtualMemberForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedGender = '男';
  String _selectedRole = '家庭成员';
  String _selectedPermission = '查看者';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '成员信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        // 姓名
        const Text(
          '姓名',
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
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '输入成员姓名',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFFA0AEC0),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 性别
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        _buildGenderSelector(),
        const SizedBox(height: 16),
        
        // 家庭称呼
        const Text(
          '家庭称呼',
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
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                hintText: '如"爸爸"、"妈妈"等亲切称呼',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFFA0AEC0),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 手机号码(可选)
        const Text(
          '手机号码 (可选)',
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
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: '输入手机号码(选填)',
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
        const SizedBox(height: 16),
        
        // 成员描述
        const Text(
          '成员描述 (可选)',
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
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '添加一些描述信息',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFFA0AEC0),
                  fontSize: 14,
                ),
              ),
            ),
          ),
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
        _buildRoleDropdown(),
        const SizedBox(height: 16),
        
        // 权限设置
        const Text(
          '权限设置',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        _buildPermissionDropdown(),
        const SizedBox(height: 24),
        
        // 添加按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _createVirtualMember,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('添加虚拟成员'),
          ),
        ),
      ],
    );
  }
  
  // 性别选择器
  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = '男'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedGender == '男'
                    ? const Color(0xFF059669)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == '男'
                      ? const Color(0xFF059669)
                      : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '男',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _selectedGender == '男'
                      ? Colors.white
                      : const Color(0xFF4B5563),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = '女'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedGender == '女'
                    ? const Color(0xFFEC4899)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == '女'
                      ? const Color(0xFFEC4899)
                      : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '女',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _selectedGender == '女'
                      ? Colors.white
                      : const Color(0xFF4B5563),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // 角色下拉菜单
  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(value: '家庭成员', child: Text('家庭成员')),
            DropdownMenuItem(value: '配偶', child: Text('配偶')),
            DropdownMenuItem(value: '子女', child: Text('子女')),
            DropdownMenuItem(value: '其他', child: Text('其他')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
        ),
      ),
    );
  }
  
  // 权限下拉菜单
  Widget _buildPermissionDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPermission,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(value: '查看者', child: Text('查看者 (仅查看)')),
            DropdownMenuItem(value: '编辑者', child: Text('编辑者 (查看和编辑)')),
            DropdownMenuItem(value: '管理员', child: Text('管理员 (完全权限)')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPermission = value!;
            });
          },
        ),
      ),
    );
  }
  
  // 创建虚拟成员
  void _createVirtualMember() {
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入成员姓名')),
      );
      return;
    }
    
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入家庭称呼')),
      );
      return;
    }
    
    // 准备成员数据
    final memberData = {
      'owner_id': widget.ownerId,
      'user_id': 0, // 虚拟成员没有用户ID
      'name': name,
      'nickname': nickname,
      'description': _descriptionController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _selectedRole,
      'permission': _selectedPermission,
      'avatar_url': '', // 虚拟成员没有头像
    };
    
    widget.onMemberCreated(memberData);
  }
}
