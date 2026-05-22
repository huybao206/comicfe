import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/auth_cultivation_widgets.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim().toLowerCase();
    if (text.isEmpty) return 'Vui lòng nhập email';
    if (!text.contains('@') || !text.contains('.')) return 'Email không hợp lệ';
    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();
      await context.read<AuthProvider>().authService.forgotPassword(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi mã OTP về email nếu tài khoản tồn tại')),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          const CultivationAuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const AuthOrnamentTitle(
                          title: 'Quên mật khẩu',
                          subtitle: 'Nhập email để nhận mã OTP đặt lại mật khẩu',
                        ),
                        const SizedBox(height: 20),
                        AuthGlassPanel(
                          child: Column(
                            children: [
                              CultivationTextField(
                                controller: _emailController,
                                validator: _validateEmail,
                                icon: Icons.email_rounded,
                                label: 'Email tài khoản',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _sendOtp(),
                              ),
                              const SizedBox(height: 18),
                              GoldAuthButton(
                                text: 'Gửi mã OTP',
                                isLoading: _isLoading,
                                onPressed: _sendOtp,
                              ),
                              const SizedBox(height: 14),
                              TextButton.icon(
                                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Quay lại đăng nhập'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFF8E6B5),
                                ),
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
          ),
        ],
      ),
    );
  }
}
