import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../utils/validators.dart';

class LoginCard extends StatelessWidget {
  final bool isLoginMode;
  final TextEditingController phoneController;
  final TextEditingController codeController;
  final FocusNode phoneFocusNode;
  final FocusNode codeFocusNode;
  final bool rememberMe;
  final bool isCodeSent;
  final int countdownSeconds;
  final Function(bool?) onRememberMeChanged;
  final VoidCallback onToggleMode;
  final Function() onSendCode;
  final Function() onSubmit;
  final Animation<double> animation;
  final String? phoneError;
  final String? codeError;

  const LoginCard({
    Key? key,
    required this.isLoginMode,
    required this.phoneController,
    required this.codeController,
    required this.phoneFocusNode,
    required this.codeFocusNode,
    required this.rememberMe,
    required this.isCodeSent,
    required this.countdownSeconds,
    required this.onRememberMeChanged,
    required this.onToggleMode,
    required this.onSendCode,
    required this.onSubmit,
    required this.animation,
    this.phoneError,
    this.codeError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      transform: Matrix4.identity()
        ..scale(1.0 + 0.02 * animation.value, 1.0 + 0.02 * animation.value),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(20, 20),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(-20, -20),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              spreadRadius: 15,
              blurRadius: 30,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _buildLogo(),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x4010B981),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.bolt,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // 应用名称
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'ZCOOL KuaiLe',
            color: Color(0xFF10B981),
            shadows: [
              Shadow(
                color: Color(0x7010B981),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Text('悦管家'),
        ),
        
        const SizedBox(height: 8),
        
        // 副标题
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            isLoginMode ? '与朋友一起享受生活的每一刻' : '加入悦管家，开启品质生活',
            key: ValueKey<bool>(isLoginMode),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 分隔线
        Container(
          height: 6,
          width: 128,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF10B981),
                Color(0xFF3B82F6),
                Color(0xFFA855F7),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        const SizedBox(height: 24),
        
        // 手机号输入框
        _buildInputField(
          controller: phoneController,
          focusNode: phoneFocusNode,
          hintText: '输入手机号，开启你的旅程',
          icon: Icons.smartphone,
          keyboardType: TextInputType.phone,
          errorText: phoneError,
          inputFormatters: [
            LengthLimitingTextInputFormatter(11),
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 验证码输入行
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: codeController,
                focusNode: codeFocusNode,
                hintText: '验证码',
                icon: Icons.lock,
                errorText: codeError,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildSendCodeButton(),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 记住我和忘记密码
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onRememberMeChanged,
                    activeColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '记住我',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // 忘记密码功能
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '忘记密码?',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // 提交按钮
        _buildSubmitButton(),
        
        const SizedBox(height: 24),
        
        // 切换登录/注册
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLoginMode ? '还没有账号？' : '已有账号？',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onToggleMode,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  isLoginMode ? '加入我们' : '直接登录',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey.withOpacity(0.3),
              width: errorText != null ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: errorText != null ? Colors.red : const Color(0xFF10B981),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSendCodeButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: isCodeSent ? null : onSendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          disabledForegroundColor: Colors.white70,
          elevation: 5,
          shadowColor: const Color(0x7010B981),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          isCodeSent ? '${countdownSeconds}s' : '获取验证码',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0x7010B981),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          isLoginMode ? '登录悦管家' : '创建我的悦管家账号',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
