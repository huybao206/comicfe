import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/auth_cultivation_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agree = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Vui lòng nhập username';

    if (text.length < 6) return 'Username phải từ 6 ký tự trở lên';

    final regex = RegExp(r'^[a-z0-9_]+$');

    if (!regex.hasMatch(text)) {
      return 'Username chỉ được chữ thường, số và dấu _';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Vui lòng nhập email';

    if (!text.contains('@') || !text.contains('.')) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  String? _validateDisplayName(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Vui lòng nhập tên hiển thị';

    return null;
  }

  String? _validatePassword(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Vui lòng nhập mật khẩu';

    if (text.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Vui lòng nhập lại mật khẩu';

    if (text != _passwordController.text.trim()) {
      return 'Mật khẩu nhập lại không khớp';
    }

    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF7A2E2E),
          content: Text('Vui lòng đồng ý điều khoản trước khi đăng ký'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final ok = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      displayName: _displayNameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2F6B3B),
          content: Text('Đăng ký thành công, đang vào app'),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          const CultivationAuthBackground(),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 54,
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFFF8E6B5),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Đăng ký',
                            style: TextStyle(
                              color: Color(0xFFF8E6B5),
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 54),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const AuthOrnamentTitle(
                              title: 'Gia nhập',
                              subtitle:
                              'Gia nhập tông môn và bắt đầu hành trình',
                            ),
                            const SizedBox(height: 14),
                            const CultivationLogo(compact: true),
                            const SizedBox(height: 10),
                            const Text(
                              'Comic Cultivation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF8E6B5),
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthGlassPanel(
                              child: Column(
                                children: [
                                  CultivationTextField(
                                    controller: _usernameController,
                                    validator: _validateUsername,
                                    icon: Icons.person_rounded,
                                    label: 'Username',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-z0-9_]'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      final lower = value.toLowerCase();

                                      if (value != lower) {
                                        _usernameController.value =
                                            TextEditingValue(
                                              text: lower,
                                              selection: TextSelection.collapsed(
                                                offset: lower.length,
                                              ),
                                            );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  CultivationTextField(
                                    controller: _emailController,
                                    validator: _validateEmail,
                                    icon: Icons.mail_rounded,
                                    label: 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 15),
                                  CultivationTextField(
                                    controller: _displayNameController,
                                    validator: _validateDisplayName,
                                    icon: Icons.badge_rounded,
                                    label: 'Tên hiển thị',
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 15),
                                  CultivationTextField(
                                    controller: _passwordController,
                                    validator: _validatePassword,
                                    icon: Icons.lock_rounded,
                                    label: 'Mật khẩu',
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFFD8C08A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  CultivationTextField(
                                    controller: _confirmPasswordController,
                                    validator: _validateConfirmPassword,
                                    icon: Icons.lock_reset_rounded,
                                    label: 'Nhập lại mật khẩu',
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) =>
                                        _handleRegister(),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFFD8C08A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _agree = !_agree;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: _agree
                                                ? const Color(0xFFD4A02F)
                                                : Colors.transparent,
                                            borderRadius:
                                            BorderRadius.circular(4),
                                            border: Border.all(
                                              color: const Color(0xFFD4A02F),
                                            ),
                                          ),
                                          child: _agree
                                              ? const Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: Color(0xFF211407),
                                          )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Tôi đồng ý với Điều khoản & Chính sách bảo mật',
                                          style: TextStyle(
                                            color: const Color(0xFFF8E6B5)
                                                .withOpacity(.66),
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  GoldAuthButton(
                                    text: 'Đăng ký',
                                    isLoading: authProvider.isLoading,
                                    onPressed: _handleRegister,
                                  ),
                                  const SizedBox(height: 16),
                                  AuthSwitchLine(
                                    normalText: 'Đã có tài khoản?',
                                    actionText: 'Đăng nhập ngay',
                                    onTap: authProvider.isLoading
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}