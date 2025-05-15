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
class GenderDropdown extends StatefulWidget {
  final String? selectedGender;
  final Function(String?) onChanged;
  
  const GenderDropdown({
    Key? key,
    required this.selectedGender,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<GenderDropdown> createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<GenderDropdown> {
  final List<Map<String, dynamic>> _genders = const [
    {'value': '男', 'icon': Icons.male, 'color': Color(0xFF3B82F6)},
    {'value': '女', 'icon': Icons.female, 'color': Color(0xFFEC4899)},
    {'value': '其他', 'icon': Icons.people, 'color': Color(0xFF6B7280)},
  ];

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部手柄
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '性别',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              
              // 分隔线
              Divider(height: 1, color: Colors.grey.shade200),
              
              // 性别选项列表
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _genders.map((gender) {
                    bool isSelected = widget.selectedGender == gender['value'];
                    return GestureDetector(
                      onTap: () {
                        widget.onChanged(gender['value']);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: gender['color'].withOpacity(isSelected ? 1.0 : 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: gender['color'],
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: gender['color'].withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: Icon(
                              gender['icon'],
                              color: isSelected ? Colors.white : gender['color'],
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            gender['value'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected 
                                  ? gender['color']
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // 底部安全区域
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  // 获取当前选中的性别图标
  IconData _getSelectedIcon() {
    if (widget.selectedGender == null || widget.selectedGender!.isEmpty) {
      return Icons.people_outline;
    }
    
    for (var gender in _genders) {
      if (gender['value'] == widget.selectedGender) {
        return gender['icon'];
      }
    }
    
    return Icons.people_outline;
  }
  
  // 获取当前选中的性别颜色
  Color _getSelectedColor() {
    if (widget.selectedGender == null || widget.selectedGender!.isEmpty) {
      return Colors.grey.shade400;
    }
    
    for (var gender in _genders) {
      if (gender['value'] == widget.selectedGender) {
        return gender['color'];
      }
    }
    
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showGenderPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getSelectedIcon(),
                  size: 20,
                  color: _getSelectedColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.selectedGender?.isNotEmpty == true
                      ? widget.selectedGender!
                      : '性别',
                  style: TextStyle(
                    color: widget.selectedGender?.isNotEmpty == true
                        ? const Color(0xFF1F2937)
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// 家庭关系下拉菜单组件
class RelationDropdown extends StatefulWidget {
  final String? selectedRelation;
  final Function(String?) onChanged;
  
  const RelationDropdown({
    Key? key,
    required this.selectedRelation,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<RelationDropdown> createState() => _RelationDropdownState();
}

class _RelationDropdownState extends State<RelationDropdown> {
  final List<Map<String, dynamic>> _relations = const [
    {'value': '配偶', 'icon': Icons.favorite, 'color': Color(0xFFEC4899)},
    {'value': '父亲', 'icon': Icons.person, 'color': Color(0xFF3B82F6)},
    {'value': '母亲', 'icon': Icons.face, 'color': Color(0xFFEC4899)},
    {'value': '儿子', 'icon': Icons.child_care, 'color': Color(0xFF3B82F6)},
    {'value': '女儿', 'icon': Icons.child_care, 'color': Color(0xFFEC4899)},
    {'value': '兄弟', 'icon': Icons.people, 'color': Color(0xFF3B82F6)},
    {'value': '姐妹', 'icon': Icons.people, 'color': Color(0xFFEC4899)},
    {'value': '祖父', 'icon': Icons.elderly, 'color': Color(0xFF3B82F6)},
    {'value': '祖母', 'icon': Icons.elderly_woman, 'color': Color(0xFFEC4899)},
    {'value': '其他', 'icon': Icons.person_outline, 'color': Color(0xFF6B7280)},
  ];

  void _showRelationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部手柄
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '选择家庭关系',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              
              // 分隔线
              Divider(height: 1, color: Colors.grey.shade200),
              
              // 关系选项列表
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 16,
                      children: _relations.map((relation) {
                        bool isSelected = widget.selectedRelation == relation['value'];
                        return GestureDetector(
                          onTap: () {
                            widget.onChanged(relation['value']);
                            Navigator.pop(context);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: relation['color'].withOpacity(isSelected ? 1.0 : 0.1),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(color: relation['color'], width: 2)
                                      : null,
                                ),
                                child: Icon(
                                  relation['icon'],
                                  color: isSelected ? Colors.white : relation['color'],
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                relation['value'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? relation['color']
                                      : const Color(0xFF4B5563),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 获取当前选中的关系图标
  IconData _getSelectedIcon() {
    if (widget.selectedRelation == null || widget.selectedRelation!.isEmpty) {
      return Icons.people_outline;
    }
    
    for (var relation in _relations) {
      if (relation['value'] == widget.selectedRelation) {
        return relation['icon'];
      }
    }
    
    return Icons.people_outline;
  }
  
  // 获取当前选中的关系颜色
  Color _getSelectedColor() {
    if (widget.selectedRelation == null || widget.selectedRelation!.isEmpty) {
      return Colors.grey.shade400;
    }
    
    for (var relation in _relations) {
      if (relation['value'] == widget.selectedRelation) {
        return relation['color'];
      }
    }
    
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showRelationPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getSelectedIcon(),
                  size: 20,
                  color: _getSelectedColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.selectedRelation?.isNotEmpty == true
                      ? widget.selectedRelation!
                      : '选择家庭关系',
                  style: TextStyle(
                    color: widget.selectedRelation?.isNotEmpty == true
                        ? const Color(0xFF1F2937)
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ],
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