import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FinancialAdvice extends StatelessWidget {
  const FinancialAdvice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "个性化财务建议",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 财务建议卡片列表
          ...List.generate(
            _adviceData.length,
            (index) => _buildAdviceCard(_adviceData[index]),
          ),
        ],
      ),
    );
  }

  // 构建单个建议卡片
  Widget _buildAdviceCard(AdviceData advice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: advice.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: advice.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: advice.iconBackgroundColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              advice.icon,
              size: 18,
              color: advice.iconColor,
            ),
          ),
          const SizedBox(width: 12),
          
          // 建议内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advice.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (advice.actionText != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      advice.actionText!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: advice.actionColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 建议数据
  static const List<AdviceData> _adviceData = [
    const AdviceData(
      icon: FontAwesomeIcons.piggyBank,
      title: "增加应急基金",
      description: "您的应急基金储备不足，建议至少积累相当于3-6个月生活开支的应急资金。",
      backgroundColor: const Color(0xFFFEF9C3),
      borderColor: const Color(0xFFFDE047),
      iconBackgroundColor: const Color(0xFFFDE047),
      iconColor: const Color(0xFFCA8A04),
      actionText: "了解更多",
      actionColor: const Color(0xFFCA8A04),
    ),
    const AdviceData(
      icon: FontAwesomeIcons.chartPie,
      title: "调整支出结构",
      description: "您在休闲娱乐方面的支出占比较高，可以考虑适当减少该项支出，增加储蓄。",
      backgroundColor: const Color(0xFFFFEDED),
      borderColor: const Color(0xFFFCA5A5),
      iconBackgroundColor: const Color(0xFFFCA5A5),
      iconColor: const Color(0xFFB91C1C),
      actionText: "查看预算管理",
      actionColor: const Color(0xFFDC2626),
    ),
    const AdviceData(
      icon: FontAwesomeIcons.moneyBillTrendUp,
      title: "增加投资配置",
      description: "您的投资收益占比较低，可以考虑增加合理的投资配置，提高资产收益率。",
      backgroundColor: const Color(0xFFDCFCE7),
      borderColor: const Color(0xFFA7F3D0),
      iconBackgroundColor: const Color(0xFFA7F3D0),
      iconColor: const Color(0xFF059669),
      actionText: "查看投资建议",
      actionColor: const Color(0xFF10B981),
    ),
  ];
}

class AdviceData {
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String? actionText;
  final Color? actionColor;
  
  const AdviceData({
    required this.icon,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.actionText,
    this.actionColor,
  });
}
