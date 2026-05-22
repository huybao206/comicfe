import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/auth_cultivation_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateOtp(String? value) {
    final text = (value ?? '').trim();
    if (!RegExp(r'^\d{6}$').hasMatch(text)) return 'OTP phải gồm 6 số';
    return null;
  }

  String? _validatePassword(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 6) return 'Mật khẩu mới phải từ 6 ký tự trở lên';
    return null;
  }

  String? _validateConfirm(String? value) {
    final text = (value ?? '').trim();
    if (text != _passwordController.text.trim()) return 'Mật khẩu nhập lại không khớp';
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().authService.resetPassword(
        email: widget.email,
        otp: _otpController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lại mật khẩu thành công. Hãy đăng nhập lại.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
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

  Future<void> _resendOtp() async {
    try {
      await context.read<AuthProvider>().authService.forgotPassword(email: widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại mã OTP')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
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
                        AuthOrnamentTitle(
                          title: 'Nhập mã OTP',
                          subtitle: 'Mã đã được gửi về ${widget.email}',
                        ),
                        const SizedBox(height: 20),
                        AuthGlassPanel(
                          child: Column(
                            children: [
                              CultivationTextField(
                                controller: _otpController,
                                validator: _validateOtp,
                                icon: Icons.password_rounded,
                                label: 'Mã OTP 6 số',
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              CultivationTextField(
                                controller: _passwordController,
                                validator: _validatePassword,
                                icon: Icons.lock_rounded,
                                label: 'Mật khẩu mới',
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFFD8C08A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CultivationTextField(
                                controller: _confirmPasswordController,
                                validator: _validateConfirm,
                                icon: Icons.lock_reset_rounded,
                                label: 'Nhập lại mật khẩu mới',
                                obscureText: _obscureConfirm,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _resetPassword(),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  icon: Icon(
                                    _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFFD8C08A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              GoldAuthButton(
                                text: 'Xác nhận đổi mật khẩu',
                                isLoading: _isLoading,
                                onPressed: _resetPassword,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _isLoading ? null : _resendOtp,
                                child: const Text('Gửi lại OTP'),
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
