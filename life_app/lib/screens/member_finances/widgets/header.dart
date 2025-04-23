import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MemberFinancesHeader extends StatelessWidget {
  final int membersCount;
  final int selectedIndex;
  final bool isCompareMode;
  final Function(int) onSelectMember;
  final VoidCallback onToggleCompareMode;
  final List<String> memberNames;
  final List<String> memberRoles;

  const MemberFinancesHeader({
    super.key,
    required this.membersCount,
    required this.selectedIndex,
    required this.isCompareMode,
    required this.onSelectMember,
    required this.onToggleCompareMode,
    required this.memberNames,
    required this.memberRoles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '家庭成员财务分析',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '查看和比较每个成员的财务状况',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onToggleCompareMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.users,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '比较模式',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(isCompareMode ? 1 : 0.7),
                          fontWeight: isCompareMode ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(
                memberNames.length,
                (index) => GestureDetector(
                  onTap: () => onSelectMember(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      index == 0 ? memberNames[index] : '${memberRoles[index]} (${memberNames[index]})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
                        color: selectedIndex == index
                            ? const Color(0xFF4F46E5)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
