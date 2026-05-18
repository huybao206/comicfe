import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../vip/screens/vip_screen.dart';
import '../provider/user_provider.dart';
import '../widgets/profile_action_grid.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_section_title.dart';
import '../widgets/profile_setting_card.dart';
import 'account_security_screen.dart';
import 'edit_profile_screen.dart';
import 'followed_comics_screen.dart';
import 'inventory_screen.dart';
import 'reading_history_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().loadMyProfile();
    });
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (!mounted) return;
    context.read<UserProvider>().loadMyProfile();
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );

    if (!mounted) return;
    context.read<UserProvider>().loadMyProfile();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10182B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: Color(0xFF7A5A26),
              width: 1.1,
            ),
          ),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(
              color: Color(0xFFFFE9B0),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Bạn có chắc muốn đăng xuất khỏi tài khoản này không?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A02F),
                foregroundColor: const Color(0xFF211407),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) return;

    if (authProvider.errorMessage != null &&
        authProvider.errorMessage!.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(authProvider.errorMessage!),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF2F6B3B),
        content: Text('Đã đăng xuất'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final profile = provider.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        onRefresh: () => context.read<UserProvider>().loadMyProfile(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            if (provider.isLoading && profile == null) ...[
              const SizedBox(height: 180),
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4A02F),
                ),
              ),
            ] else if (provider.errorMessage != null && profile == null) ...[
              const SizedBox(height: 130),
              _ProfileErrorView(
                message: provider.errorMessage!,
                onRetry: () =>
                    context.read<UserProvider>().loadMyProfile(),
              ),
            ] else if (profile != null) ...[
              ProfileHeader(
                profile: profile,
                onEdit: _openEditProfile,
              ),

              const SizedBox(height: 14),

              ProfileInfoCard(profile: profile),

              const SizedBox(height: 18),

              const ProfileSectionTitle(
                title: 'Tiện ích cá nhân',
                icon: Icons.dashboard_customize_outlined,
                action: 'Hoạt động',
              ),

              const SizedBox(height: 10),

              ProfileActionGrid(
                items: [
                  ProfileActionItemData(
                    icon: Icons.menu_book_outlined,
                    title: 'Đã đọc',
                    subtitle: '${profile.totalReadChapters} chương',
                    color: const Color(0xFF8FB0FF),
                    onTap: () => _openPage(
                      const ReadingHistoryScreen(),
                    ),
                  ),
                  ProfileActionItemData(
                    icon: Icons.favorite_border_rounded,
                    title: 'Theo dõi',
                    subtitle: '${profile.totalFollowedComics} truyện',
                    color: const Color(0xFFFF7AA8),
                    onTap: () => _openPage(
                      const FollowedComicsScreen(),
                    ),
                  ),
                  ProfileActionItemData(
                    icon: Icons.workspace_premium_outlined,
                    title: 'VIP',
                    subtitle: profile.vipDisplayName,
                    color: const Color(0xFFFFD27A),
                    onTap: () => _openPage(
                      const VipScreen(),
                    ),
                  ),
                  ProfileActionItemData(
                    icon: Icons.inventory_2_outlined,
                    title: 'Túi đồ',
                    subtitle: 'Vật phẩm sở hữu',
                    color: const Color(0xFF4ADE80),
                    onTap: () => _openPage(
                      const InventoryScreen(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const ProfileSectionTitle(
                title: 'Thiết lập',
                icon: Icons.settings_outlined,
                action: 'Tài khoản',
              ),

              const SizedBox(height: 10),

              ProfileSettingCard(
                icon: Icons.person_outline_rounded,
                title: 'Chỉnh sửa hồ sơ',
                subtitle: 'Cập nhật tên hiển thị và thông tin tài khoản',
                color: const Color(0xFFFFD27A),
                onTap: _openEditProfile,
              ),

              const SizedBox(height: 10),

              ProfileSettingCard(
                icon: Icons.security_rounded,
                title: 'Bảo mật tài khoản',
                subtitle: 'Quản lý đăng nhập và quyền riêng tư',
                color: const Color(0xFF8FB0FF),
                onTap: () => _openPage(
                  const AccountSecurityScreen(),
                ),
              ),

              const SizedBox(height: 10),

              ProfileSettingCard(
                icon: Icons.help_outline_rounded,
                title: 'Hỗ trợ',
                subtitle: 'Giải đáp thắc mắc và gửi phản hồi',
                color: const Color(0xFF4ADE80),
                onTap: () => _openPage(
                  const SupportScreen(),
                ),
              ),

              const SizedBox(height: 18),

              _LogoutButton(
                isLoading: authProvider.isLoading,
                onTap: _handleLogout,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFFC9C9),
          ),
        )
            : const Icon(Icons.logout_rounded),
        label: Text(
          isLoading ? 'Đang đăng xuất...' : 'Đăng xuất',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFC9C9),
          backgroundColor: const Color(0xFF7A2E2E).withOpacity(0.10),
          side: const BorderSide(color: Color(0xFF7A2E2E)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFFD27A),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không tải được hồ sơ',
            style: TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.54),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Tải lại',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4A02F),
              foregroundColor: const Color(0xFF211407),
            ),
          ),
        ],
      ),
    );
  }
}