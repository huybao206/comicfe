import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../widgets/profile_action_grid.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_section_title.dart';
import '../widgets/profile_setting_card.dart';
import 'edit_profile_screen.dart';

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

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng đang phát triển')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
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
                    onTap: _showComingSoon,
                  ),
                  ProfileActionItemData(
                    icon: Icons.favorite_border_rounded,
                    title: 'Theo dõi',
                    subtitle: 'Truyện yêu thích',
                    onTap: _showComingSoon,
                  ),
                  ProfileActionItemData(
                    icon: Icons.workspace_premium_rounded,
                    title: 'VIP',
                    subtitle: 'Đặc quyền tu luyện',
                    onTap: _showComingSoon,
                  ),
                  ProfileActionItemData(
                    icon: Icons.inventory_2_outlined,
                    title: 'Túi đồ',
                    subtitle: 'Vật phẩm sở hữu',
                    onTap: _showComingSoon,
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
                onTap: _showComingSoon,
              ),
              const SizedBox(height: 10),
              ProfileSettingCard(
                icon: Icons.help_outline_rounded,
                title: 'Hỗ trợ',
                subtitle: 'Giải đáp thắc mắc và phản hồi',
                onTap: _showComingSoon,
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn có thể nối logout tại đây'),
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất'),
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