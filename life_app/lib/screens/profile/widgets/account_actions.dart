import 'package:flutter/material.dart';

class AccountActionItem {
  final String title;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final bool isWarning;
  final VoidCallback onTap;
  
  AccountActionItem({
    required this.title,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.isWarning = false,
    required this.onTap,
  });
}

class AccountActions extends StatelessWidget {
  final List<AccountActionItem> actions;
  
  const AccountActions({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: actions.map((action) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // 图标
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: action.iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.icon,
                        color: action.iconColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 标题
                    Expanded(
                      child: Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: action.isWarning 
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    // 箭头
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFD1D5DB),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
