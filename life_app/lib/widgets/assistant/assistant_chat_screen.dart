import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // 添加欢迎消息
    _addAssistantMessage(
      "你好，我是小财！我可以帮你：\n"
      "• 分析支出模式\n"
      "• 提供节省建议\n"
      "• 回答财务问题\n"
      "• 设置账单提醒\n\n"
      "有什么我能帮到你的吗？",
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addAssistantMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // 确保滚动到底部是在下一帧执行的
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 模拟智能助手回复
  void _simulateAssistantResponse(String userMessage) {
    setState(() {
      _isTyping = true;
    });

    // 基于用户输入生成回复
    Future.delayed(const Duration(seconds: 1), () {
      String response = "";
      
      if (userMessage.contains('支出') || userMessage.contains('花钱')) {
        response = "根据你的消费记录，过去一个月你在餐饮上支出占总支出的35%，这比上个月增加了5%。要不要我帮你分析一下节省的方法？";
      } else if (userMessage.contains('预算') || userMessage.contains('省钱')) {
        response = "我建议你设置每个分类的预算上限，比如餐饮可以控制在每月2000元以内。另外，周末做饭代替外卖可以节省大约30%的餐饮开支。";
      } else if (userMessage.contains('账单') || userMessage.contains('提醒')) {
        response = "好的，我已为你设置了每月15号的信用卡还款提醒和每月25号的房租提醒。需要我再添加其他提醒吗？";
      } else if (userMessage.contains('投资') || userMessage.contains('理财')) {
        response = "基于你的风险偏好和当前财务状况，我建议配置60%稳健型和40%增长型的投资组合。要了解更多详情吗？";
      } else {
        response = "作为你的财务小助手，我可以帮你分析支出模式、提供预算建议、设置账单提醒，以及回答各种财务问题。你有什么具体需求吗？";
      }

      setState(() {
        _isTyping = false;
        _addAssistantMessage(response);
      });
    });
  }

  void _handleSubmit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();
    _simulateAssistantResponse(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.assistantBackground,
              radius: 14,
              child: Text(
                '小',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('小财助手'),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 建议标签
          _buildSuggestionTags(),
          
          // 聊天消息列表
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          
          // 底部输入框
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestionTags() {
    final suggestions = [
      '本月支出分析',
      '如何省钱',
      '设置账单提醒',
      '投资建议',
      '预算管理技巧',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: InkWell(
              onTap: () {
                _messageController.text = suggestions[index];
                _handleSubmit();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.assistantBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.assistantBackground.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  suggestions[index],
                  style: TextStyle(
                    color: AppTheme.assistantBackground,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAssistantAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.primaryColor : AppTheme.assistantBubble,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return const CircleAvatar(
      backgroundColor: AppTheme.assistantBackground,
      radius: 16,
      child: Text(
        '小',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return const CircleAvatar(
      backgroundColor: Colors.grey,
      radius: 16,
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAssistantAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.assistantBubble,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          // 使用动画控制器和固定的延迟来创建波浪效果
          AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1500),
          )..repeat(),
        ]),
        builder: (context, child) {
          // 根据索引添加延迟
          final delay = index * 0.3;
          final time = DateTime.now().millisecondsSinceEpoch / 500;
          final offset = math.sin((time + delay) % math.pi);

          return Transform.translate(
            offset: Offset(0, -2 * offset),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.assistantBackground,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 语音输入按钮 - 将来实现
            IconButton(
              icon: const Icon(Icons.mic_none, color: AppTheme.primaryColor),
              onPressed: () {
                // 实现语音输入
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('语音输入功能即将上线')),
                );
              },
            ),
            // 文本输入框
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '发送消息给小财...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
            const SizedBox(width: 8),
            // 发送按钮
            IconButton(
              icon: const Icon(Icons.send, color: AppTheme.primaryColor),
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
