import 'package:flutter/material.dart';

/// 通用表单字段组件
class FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool isRequired;
  
  const FormField({
    Key? key,
    required this.label,
    required this.controller,
    required this.placeholder,
    this.isRequired = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
            if (!isRequired)
              Text(
                ' (可选)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 性别下拉菜单组件
class GenderDropdown extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onChanged;
  
  const GenderDropdown({
    Key? key,
    required this.selectedGender,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('选择性别'),
            value: selectedGender?.isEmpty == true ? null : selectedGender,
            items: const [
              DropdownMenuItem(value: '男', child: Text('男')),
              DropdownMenuItem(value: '女', child: Text('女')),
              DropdownMenuItem(value: '其他', child: Text('其他'))
            ],
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
            ),
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}

/// 家庭关系下拉菜单组件
class RelationDropdown extends StatelessWidget {
  final String? selectedRelation;
  final Function(String?) onChanged;
  
  const RelationDropdown({
    Key? key,
    required this.selectedRelation,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('选择家庭关系'),
            value: selectedRelation?.isEmpty == true ? null : selectedRelation,
            items: const [
              DropdownMenuItem(value: '配偶', child: Text('配偶')),
              DropdownMenuItem(value: '父亲', child: Text('父亲')),
              DropdownMenuItem(value: '母亲', child: Text('母亲')),
              DropdownMenuItem(value: '儿子', child: Text('儿子')),
              DropdownMenuItem(value: '女儿', child: Text('女儿')),
              DropdownMenuItem(value: '兄弟', child: Text('兄弟')),
              DropdownMenuItem(value: '姐妹', child: Text('姐妹')),
              DropdownMenuItem(value: '祖父', child: Text('祖父')),
              DropdownMenuItem(value: '祖母', child: Text('祖母')),
              DropdownMenuItem(value: '其他', child: Text('其他'))
            ],
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
            ),
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}

/// 权限列表组件
class PermissionsList extends StatelessWidget {
  final List<bool> permissions;
  final Function(int, bool?) onChanged;
  
  const PermissionsList({
    Key? key,
    required this.permissions,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final permissionItems = [
      {
        'title': '记录个人支出',
        'description': '可以添加自己的收支记录',
      },
      {
        'title': '查看家庭收支',
        'description': '可以查看家庭总体收支情况',
      },
      {
        'title': '修改家庭账目',
        'description': '可以修改其他成员的收支记录',
      },
      {
        'title': '管理家庭预算',
        'description': '可以设置和调整家庭预算',
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        permissionItems.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: permissions[index],
                  onChanged: (value) => onChanged(index, value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permissionItems[index]['title']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      permissionItems[index]['description']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 操作按钮组件
class ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isEditing;
  final int currentTab;
  final bool? userFound;
  
  const ActionButtons({
    Key? key,
    required this.onCancel,
    required this.onSubmit,
    this.isEditing = false,
    this.currentTab = 0,
    this.userFound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 取消按钮
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('取消'),
        ),
        const SizedBox(width: 12),
        // 提交按钮
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEditing
                  ? '保存修改'
                  : (currentTab == 0 
                      ? (userFound == true ? '添加成员' : '查询') 
                      : '提交')),
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

/// 获取权限文本
String getPermissionText(List<bool> permissions) {
  if (permissions[0]) {
    return "管理员";
  } else if (permissions[1]) {
    return "编辑者";
  } else {
    return "查看者";
  }
} 