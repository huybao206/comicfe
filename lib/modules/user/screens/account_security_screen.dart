import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/user_provider.dart';

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
              title: 'Đổi mật khẩu',
              subtitle: 'Backend hiện chưa có API đổi mật khẩu, cần bổ sung endpoint riêng nếu muốn dùng thật',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chưa có API đổi mật khẩu trong backend hiện tại'),
                  ),
                );
              },
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

String _formatDate(DateTime? value) {
  if (value == null) return 'Chưa rõ';
  return "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
}
