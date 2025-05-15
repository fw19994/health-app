import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/family_member_model.dart';

class MemberContributionsWidget extends StatelessWidget {
  final List<FamilyMember> members;
  final bool isLoading;
  final Function(FamilyMember) onMemberDetails; // 成员详情点击回调
  final double totalIncome;
  final double totalExpense;

  const MemberContributionsWidget({
    Key? key,
    required this.members,
    required this.isLoading,
    required this.onMemberDetails, // 新参数：成员详情回调
    required this.totalIncome,
    required this.totalExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 格式化总金额
    final String formattedTotalIncome = '¥${totalIncome.toStringAsFixed(2)}';
    final String formattedTotalExpense = '¥${totalExpense.toStringAsFixed(2)}';
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题 - 移除"查看详细分析"按钮
          const Text(
            '家庭成员财务',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 成员列表
          if (isLoading)
            // 加载中显示骨架屏
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (members.isEmpty)
            // 没有成员时显示提示
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '暂无家庭成员数据',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              members.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _buildMemberFinancialItem(context, members[index], index),
              ),
            ),
          
          // 总体占比图表
          if (members.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '家庭成员财务占比',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 收入和支出饼图并排
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 收入占比图
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              '收入占比',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            _buildContributionPieChart(
                              members,
                              isIncome: true,
                              total: formattedTotalIncome,
                              centerLabel: '总收入',
                            ),
                          ],
                        ),
                      ),
                      // 支出占比图
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              '支出占比',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            _buildContributionPieChart(
                              members,
                              isIncome: false,
                              total: formattedTotalExpense,
                              centerLabel: '总支出',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 图例 - 尽量在一行显示
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: members.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: _buildLegendItem(
                            members[index].nickname.isNotEmpty ? members[index].nickname : members[index].name,
                            _getMemberColor(index),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // 结余状态
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '目前家庭结余状态',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '收支平衡',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 获取成员颜色
  Color _getMemberColor(int index) {
    // 为1-20位成员设置固定且各不相同的颜色
    final List<Color> memberColors = [
      const Color(0xFF6366F1), // 靛蓝色
      const Color(0xFFEC4899), // 粉色
      const Color(0xFFF59E0B), // 琥珀色
      const Color(0xFF10B981), // 绿色
      const Color(0xFFEF4444), // 红色
      const Color(0xFF8B5CF6), // 紫色
      const Color(0xFF3B82F6), // 蓝色
      const Color(0xFFF97316), // 橙色
      const Color(0xFF14B8A6), // 青色
      const Color(0xFFA855F7), // 紫罗兰
      const Color(0xFF06B6D4), // 天蓝色
      const Color(0xFFDB2777), // 深粉色
      const Color(0xFF22C55E), // 翠绿色
      const Color(0xFF64748B), // 石板蓝
      const Color(0xFFD97706), // 棕色
      const Color(0xFF7C3AED), // 深紫色
      const Color(0xFFEAB308), // 金黄色
      const Color(0xFF0EA5E9), // 浅蓝色
      const Color(0xFF78716C), // 棕灰色
      const Color(0xFF9333EA), // 中紫色
    ];
    
    return memberColors[index % memberColors.length];
  }
  
  // 成员财务项
  Widget _buildMemberFinancialItem(BuildContext context, FamilyMember member, int index) {
    final color = _getMemberColor(index);
    
    // 使用成员模型中的真实财务数据
    final double income = member.income;
    final double expense = member.expense;
    final double balance = member.balance;
    final double expensePercentage = member.expensePercentage;
    final double incomePercentage = member.incomePercentage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 成员头像
            CircleAvatar(
              radius: 24,
              backgroundImage: member.avatarUrl.isNotEmpty 
                ? NetworkImage(member.avatarUrl) 
                : null,
              child: member.avatarUrl.isEmpty
                ? Text(
                    member.name.isNotEmpty ? member.name[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
              backgroundColor: member.avatarUrl.isEmpty 
                ? Colors.blueGrey 
                : null,
            ),
            const SizedBox(width: 12),
            // 成员名称和关系
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      children: [
                        TextSpan(text: member.nickname.isNotEmpty ? member.nickname : member.name),
                        TextSpan(
                          text: ' (${member.role})',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '收入: ${incomePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '支出: ${expensePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 添加详情按钮
            IconButton(
              icon: const Icon(Icons.chevron_right),
              color: Colors.grey[600],
              onPressed: () => onMemberDetails(member),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              splashRadius: 24,
              tooltip: '查看详情',
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 财务数据卡片 - 添加点击事件
        InkWell(
          onTap: () => onMemberDetails(member),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                // 收入
                Expanded(
                  child: _buildFinancialDataItem(
                    icon: FontAwesomeIcons.arrowDown,
                    iconColor: Colors.green,
                    label: '收入',
                    value: '¥${income.toStringAsFixed(2)}',
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                // 支出
                Expanded(
                  child: _buildFinancialDataItem(
                    icon: FontAwesomeIcons.arrowUp,
                    iconColor: Colors.red,
                    label: '支出',
                    value: '¥${expense.toStringAsFixed(2)}',
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                // 结余
                Expanded(
                  child: _buildFinancialDataItem(
                    icon: FontAwesomeIcons.scaleBalanced,
                    iconColor: Colors.blue,
                    label: '结余',
                    value: '¥${balance.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 贡献进度条部分 - 收入与支出进度条
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '收入贡献',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: incomePercentage / 100,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '支出贡献',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: expensePercentage / 100,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // 财务数据项
  Widget _buildFinancialDataItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 12,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
  
  // 贡献占比饼图
  Widget _buildContributionPieChart(List<FamilyMember> members, {
    required bool isIncome,
    required String total,
    required String centerLabel,
  }) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: PieChartPainter(
          segments: members.asMap().entries.map((entry) {
            int index = entry.key;
            FamilyMember member = entry.value;
            
            // 使用成员模型中的真实财务数据
            double percentage = isIncome 
                ? member.incomePercentage 
                : member.expensePercentage;
            
            return PieSegment(
              value: percentage,
              color: _getMemberColor(index),
            );
          }).toList(),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 图例项
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// 饼图绘制器
class PieChartPainter extends CustomPainter {
  final List<PieSegment> segments;
  
  PieChartPainter({required this.segments});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    double startAngle = -90 * (3.14159 / 180); // 从12点钟方向开始
    
    // 计算总值，用于计算每个段的角度
    final totalValue = segments.fold(0.0, (sum, segment) => sum + segment.value);
    
    for (final segment in segments) {
      final sweepAngle = (segment.value / totalValue) * 2 * 3.14159;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
    
    // 画中间的空心
    final innerRadius = radius * 0.6;
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 饼图段数据模型
class PieSegment {
  final double value;
  final Color color;
  
  PieSegment({required this.value, required this.color});
} 