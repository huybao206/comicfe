import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/user_provider.dart';
import 'package:my_book/core/widgets/app_top_toast.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<UserProvider>();
      if (provider.profile == null) provider.loadMyProfile();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF17110C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF735624)),
        ),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản này không?',
          style: TextStyle(color: Color(0xFFE8D7B3), height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC7962F),
              foregroundColor: const Color(0xFF24170B),
            ),
            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await context.read<AuthProvider>().logout();

    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _openChangePasswordOtpDialog() async {
    final profile = context.read<UserProvider>().profile;
    final email = profile?.email ?? '';
    final otpController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool otpSent = false;
    bool isSendingOtp = false;
    bool isSubmitting = false;
    bool obscurePassword = true;
    bool obscureConfirm = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !isSubmitting,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> requestOtp() async {
                setDialogState(() => isSendingOtp = true);
                try {
                  await context.read<AuthProvider>().authService.requestChangePasswordOtp();
                  if (!context.mounted) return;
                  setDialogState(() => otpSent = true);
                  AppTopToast.fromSnackBar(context,
                    SnackBar(content: Text('Đã gửi mã OTP về email ${email.isNotEmpty ? email : 'của bạn'}')),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  AppTopToast.fromSnackBar(context,
                    SnackBar(
                      backgroundColor: const Color(0xFF7A2E2E),
                      content: Text(error.toString().replaceFirst('Exception: ', '')),
                    ),
                  );
                } finally {
                  if (context.mounted) setDialogState(() => isSendingOtp = false);
                }
              }

              Future<void> confirmChangePassword() async {
                if (!formKey.currentState!.validate()) return;

                setDialogState(() => isSubmitting = true);
                try {
                  await context.read<AuthProvider>().authService.confirmChangePasswordWithOtp(
                    otp: otpController.text.trim(),
                    newPassword: passwordController.text.trim(),
                  );

                  if (!context.mounted) return;
                  Navigator.of(dialogContext).pop();
                  AppTopToast.fromSnackBar(context,
                    const SnackBar(content: Text('Đổi mật khẩu thành công')),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  AppTopToast.fromSnackBar(context,
                    SnackBar(
                      backgroundColor: const Color(0xFF7A2E2E),
                      content: Text(error.toString().replaceFirst('Exception: ', '')),
                    ),
                  );
                } finally {
                  if (context.mounted) setDialogState(() => isSubmitting = false);
                }
              }

              return AlertDialog(
                backgroundColor: const Color(0xFF17110C),
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(color: Color(0xFF735624)),
                ),
                title: const Text(
                  'Đổi mật khẩu bằng OTP',
                  style: TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900),
                ),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email.isNotEmpty
                                ? 'Mã OTP sẽ được gửi về email: $email'
                                : 'Mã OTP sẽ được gửi về email tài khoản của bạn.',
                            style: const TextStyle(color: Color(0xFFE8D7B3), height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: (isSendingOtp || isSubmitting) ? null : requestOtp,
                              icon: isSendingOtp
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Icon(Icons.email_rounded),
                              label: Text(otpSent ? 'Gửi lại mã OTP' : 'Gửi mã OTP'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFC7962F),
                                foregroundColor: const Color(0xFF24170B),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SecurityTextField(
                            controller: otpController,
                            label: 'Mã OTP 6 số',
                            icon: Icons.password_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (!RegExp(r'^\d{6}$').hasMatch(text)) return 'OTP phải gồm 6 số';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _SecurityTextField(
                            controller: passwordController,
                            label: 'Mật khẩu mới',
                            icon: Icons.lock_rounded,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                              icon: Icon(
                                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFFE0B85C),
                              ),
                            ),
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.length < 6) return 'Mật khẩu mới phải từ 6 ký tự trở lên';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _SecurityTextField(
                            controller: confirmPasswordController,
                            label: 'Nhập lại mật khẩu mới',
                            icon: Icons.lock_reset_rounded,
                            obscureText: obscureConfirm,
                            suffixIcon: IconButton(
                              onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                              icon: Icon(
                                obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFFE0B85C),
                              ),
                            ),
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text != passwordController.text.trim()) return 'Mật khẩu nhập lại không khớp';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
                  ),
                  FilledButton(
                    onPressed: isSubmitting ? null : confirmChangePassword,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC7962F),
                      foregroundColor: const Color(0xFF24170B),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Xác nhận đổi', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      otpController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final profile = userProvider.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        title: const Text('Bảo mật tài khoản'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0A07),
        foregroundColor: const Color(0xFFF6E7BE),
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: () => context.read<UserProvider>().loadMyProfile(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF17110C),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF735624)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: Color(0xFFE0B85C)),
                      SizedBox(width: 10),
                      Text(
                        'Thông tin đăng nhập',
                        style: TextStyle(
                          color: Color(0xFFF6E7BE),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Tài khoản', value: profile?.username ?? 'Đang tải...'),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Email', value: profile?.email ?? 'Đang tải...'),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Ngày tạo',
                    value: _formatDate(profile?.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SecurityActionCard(
              icon: Icons.refresh_rounded,
              title: 'Tải lại thông tin tài khoản',
              subtitle: 'Đồng bộ lại dữ liệu mới nhất từ máy chủ',
              onTap: () => context.read<UserProvider>().loadMyProfile(),
            ),
            const SizedBox(height: 10),
            _SecurityActionCard(
              icon: Icons.lock_reset_rounded,
              title: 'Đổi mật khẩu bằng OTP',
              subtitle: 'Gửi mã OTP về email, nhập mã xác nhận rồi mới đổi mật khẩu',
              onTap: _openChangePasswordOtpDialog,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: authProvider.isLoading ? null : _logout,
              icon: authProvider.isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFC9C9)),
              )
                  : const Icon(Icons.logout_rounded),
              label: Text(authProvider.isLoading ? 'Đang đăng xuất...' : 'Đăng xuất khỏi thiết bị này'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFC9C9),
                side: const BorderSide(color: Color(0xFF7A2E2E)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: const TextStyle(color: Color(0xFFB89E70), fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Chưa cập nhật',
            style: const TextStyle(color: Color(0xFFE8D7B3), fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SecurityActionCard extends StatelessWidget {
  const _SecurityActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF17110C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF735624)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF23180F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF5E451D)),
              ),
              child: Icon(icon, color: const Color(0xFFE0B85C), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFFCCB991), fontSize: 12.5, height: 1.35),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD2B06D)),
          ],
        ),
      ),
    );
  }
}

class _SecurityTextField extends StatelessWidget {
  const _SecurityTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB89E70)),
        prefixIcon: Icon(icon, color: const Color(0xFFE0B85C)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0E182C),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2B3D6A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC7962F)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB84A4A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFA0A0)),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Chưa rõ';
  return "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
}
