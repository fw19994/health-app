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
  final VoidCallback? onNetworkDiagnostics;

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
    this.onNetworkDiagnostics,
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
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 12),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color(0x5010B981),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.bolt,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 应用名称
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'ZCOOL KuaiLe',
            color: Color(0xFF10B981),
            shadows: [
              Shadow(
                color: Color(0x5010B981),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Text('悦管家'),
        ),
        
        const SizedBox(height: 4),
        
        // 副标题
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            isLoginMode ? '与朋友一起享受生活的每一刻' : '加入悦管家，开启品质生活',
            key: ValueKey<bool>(isLoginMode),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        
        // 手机号输入框
        _buildInputField(
          controller: phoneController,
          focusNode: phoneFocusNode,
          hintText: '输入手机号',
          icon: Icons.smartphone,
          keyboardType: TextInputType.phone,
          errorText: phoneError,
          inputFormatters: [
            LengthLimitingTextInputFormatter(11),
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 验证码输入行
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: codeController,
                focusNode: codeFocusNode,
                hintText: '验证码',
                icon: Icons.lock_outline,
                errorText: codeError,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(width: 10),
            _buildSendCodeButton(),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 记住我和忘记密码
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onRememberMeChanged,
                    activeColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '记住我',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (onNetworkDiagnostics != null)
                  IconButton(
                    icon: const Icon(
                      Icons.wifi_tethering,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    onPressed: onNetworkDiagnostics,
                    tooltip: '网络诊断',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 8),
                    visualDensity: VisualDensity.compact,
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
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 提交按钮
        _buildSubmitButton(),
        
        const SizedBox(height: 14),
        
        // 切换登录/注册
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLoginMode ? '还没有账号？' : '已有账号？',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
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
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (onNetworkDiagnostics != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '登录遇到问题？',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onNetworkDiagnostics,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '点击进行网络诊断',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // 字段标签
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            keyboardType == TextInputType.phone ? '手机号码' : '验证码',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 输入框
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                ? Colors.red.withOpacity(0.6) 
                : focusNode.hasFocus 
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE2E8F0),
              width: errorText != null || focusNode.hasFocus ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (focusNode.hasFocus) 
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  icon,
                  size: 20,
                  color: errorText != null 
                    ? Colors.red
                    : focusNode.hasFocus
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                // 使用Theme包装TextField以覆盖系统默认的焦点行为
                child: Theme(
                  data: ThemeData(
                    // 禁用默认的焦点高亮
                    inputDecorationTheme: const InputDecorationTheme(
                      focusedBorder: InputBorder.none,
                      focusColor: Colors.transparent,
                    ),
                    // 设置透明的焦点高亮颜色
                    colorScheme: const ColorScheme.light(
                      primary: Colors.transparent,
                    ),
                    // 禁用涟漪效果
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusColor: Colors.transparent,
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    hintStyle: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                    cursorColor: const Color(0xFF10B981), // 设置光标颜色与主题一致
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // 清除按钮
              if (controller.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => controller.clear(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  errorText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSendCodeButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isCodeSent ? null : onSendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: isCodeSent ? 0 : 2,
          shadowColor: const Color(0x7010B981),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCodeSent 
                ? Colors.transparent 
                : const Color(0xFF10B981).withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: isCodeSent 
          ? Text(
              '${countdownSeconds}s',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )
          : const Text(
              '获取验证码',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF0D9488)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLoginMode ? Icons.login : Icons.person_add,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isLoginMode ? '登录悦管家' : '创建我的悦管家账号',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

