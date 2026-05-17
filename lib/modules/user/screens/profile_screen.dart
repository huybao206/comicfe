import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/user_provider.dart';
import '../widgets/profile_action_grid.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_section_title.dart';
import '../../vip/screens/vip_screen.dart';
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
          backgroundColor: const Color(0xFF15110C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8B6A2B), width: 1.2),
          ),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(
              color: Color(0xFFF6E7BE),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Bạn có chắc muốn đăng xuất khỏi tài khoản này không?',
            style: TextStyle(
              color: Color(0xFFE8D7B3),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC7962F),
                foregroundColor: const Color(0xFF24170B),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.w800),
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
      backgroundColor: const Color(0xFF0D0A07),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: () => context.read<UserProvider>().loadMyProfile(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (provider.isLoading && profile == null) ...[
              const SizedBox(height: 160),
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC7962F),
                ),
              ),
            ] else if (provider.errorMessage != null && profile == null) ...[
              const SizedBox(height: 140),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE6D5B0),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ProfileHeader(
                displayName: _displayName(
                  profile?.displayName,
                  profile?.username,
                ),
                username: profile?.username ?? '',
                email: profile?.email ?? '',
                avatarUrl: profile?.avatarUrl,
                onEdit: _openEditProfile,
              ),
              const SizedBox(height: 16),
              ProfileInfoCard(
                email: profile?.email ?? '',
                username: profile?.username ?? '',
              ),
              const SizedBox(height: 16),
              const ProfileSectionTitle(title: 'Tiện ích cá nhân'),
              const SizedBox(height: 10),
              ProfileActionGrid(
                items: [
                  ProfileActionItemData(
                    icon: Icons.history_rounded,
                    title: 'Lịch sử đọc',
                    subtitle: 'Theo dõi tiến độ',
                    onTap: () => _openPage(const ReadingHistoryScreen()),
                  ),
                  ProfileActionItemData(
                    icon: Icons.favorite_border_rounded,
                    title: 'Theo dõi',
                    subtitle: 'Truyện yêu thích',
                    onTap: () => _openPage(const FollowedComicsScreen()),
                  ),
                  ProfileActionItemData(
                    icon: Icons.workspace_premium_rounded,
                    title: 'VIP',
                    subtitle: 'Đặc quyền tu luyện',
                    onTap: () => _openPage(const VipScreen()),
                  ),
                  ProfileActionItemData(
                    icon: Icons.inventory_2_outlined,
                    title: 'Túi đồ',
                    subtitle: 'Vật phẩm sở hữu',
                    onTap: () => _openPage(const InventoryScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const ProfileSectionTitle(title: 'Thiết lập'),
              const SizedBox(height: 10),
              ProfileSettingCard(
                icon: Icons.person_outline_rounded,
                title: 'Chỉnh sửa hồ sơ',
                subtitle: 'Hiển thị thông tin tài khoản hiện có',
                onTap: _openEditProfile,
              ),
              const SizedBox(height: 10),
              ProfileSettingCard(
                icon: Icons.security_rounded,
                title: 'Bảo mật tài khoản',
                subtitle: 'Quản lý thông tin đăng nhập',
                onTap: () => _openPage(const AccountSecurityScreen()),
              ),
              const SizedBox(height: 10),
              ProfileSettingCard(
                icon: Icons.help_outline_rounded,
                title: 'Hỗ trợ',
                subtitle: 'Giải đáp thắc mắc và phản hồi',
                onTap: () => _openPage(const SupportScreen()),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: authProvider.isLoading ? null : _handleLogout,
                icon: authProvider.isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFC9C9),
                  ),
                )
                    : const Icon(Icons.logout_rounded),
                label: Text(authProvider.isLoading ? 'Đang đăng xuất...' : 'Đăng xuất'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFC9C9),
                  side: const BorderSide(color: Color(0xFF7A2E2E)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _displayName(String? displayName, String? username) {
    if ((displayName ?? '').trim().isNotEmpty) return displayName!.trim();
    if ((username ?? '').trim().isNotEmpty) return username!.trim();
    return 'Đạo hữu';
  }
}