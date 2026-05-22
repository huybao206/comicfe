import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/auth_cultivation_widgets.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'package:my_book/core/widgets/app_top_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Vui lòng nhập email hoặc username';

    if (!text.contains('@') && text.length < 6) {
      return 'Username phải từ 6 ký tự trở lên';
    }

    if (text.contains('@') && (!text.contains('.') || text.startsWith('@'))) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) return 'Vui lòng nhập mật khẩu';

    if (text.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';

    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final ok = await authProvider.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!ok) {
      AppTopToast.fromSnackBar(context,
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
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
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const AuthOrnamentTitle(
                          title: 'Đăng nhập',
                          subtitle: 'Mở cổng tu luyện và tiếp tục hành trình',
                        ),
                        const SizedBox(height: 20),
                        const CultivationLogo(),
                        const SizedBox(height: 8),
                        const Text(
                          'Comic Cultivation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF8E6B5),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: .4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đăng nhập để tiếp tục hành trình tu luyện',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFF8E6B5).withOpacity(.68),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 22),
                        AuthGlassPanel(
                          child: Column(
                            children: [
                              CultivationTextField(
                                controller: _identifierController,
                                validator: _validateIdentifier,
                                icon: Icons.person_rounded,
                                label: 'Email hoặc username',
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              CultivationTextField(
                                controller: _passwordController,
                                validator: _validatePassword,
                                icon: Icons.lock_rounded,
                                label: 'Mật khẩu',
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
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
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4A02F),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Color(0xFF211407),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ghi nhớ đăng nhập',
                                    style: TextStyle(
                                      color: const Color(0xFFF8E6B5)
                                          .withOpacity(.68),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: authProvider.isLoading
                                        ? null
                                        : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Quên mật khẩu?',
                                      style: TextStyle(
                                        color: const Color(0xFFE0B85C).withOpacity(.95),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              GoldAuthButton(
                                text: 'Đăng nhập',
                                isLoading: authProvider.isLoading,
                                onPressed: _handleLogin,
                              ),
                              const SizedBox(height: 18),
                              AuthSwitchLine(
                                normalText: 'Chưa có tài khoản?',
                                actionText: 'Đăng ký ngay',
                                onTap: authProvider.isLoading
                                    ? null
                                    : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const RegisterScreen(),
                                    ),
                                  );
                                },
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