import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../model/guild.dart';
import '../model/guild_member.dart';
import '../provider/guild_provider.dart';
import '../widgets/create_guild_dialog.dart';
import '../widgets/guild_empty_view.dart';
import '../widgets/guild_header.dart';
import '../widgets/guild_list_card.dart';
import '../widgets/guild_member_tile.dart';
import '../widgets/guild_section_card.dart';
import '../widgets/guild_stat_card.dart';

class GuildScreen extends StatefulWidget {
  const GuildScreen({super.key});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<GuildProvider>().loadGuildHome();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateGuildDialog() async {
    final ok = await showCreateGuildDialog(context);

    if (!mounted) return;

    final provider = context.read<GuildProvider>();

    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2F6B3B),
          content: Text('Tạo bang hội thành công'),
        ),
      );

      await provider.loadGuildHome();
    }
  }


  Future<void> _checkinGuild() async {
    final data = await context.read<GuildProvider>().checkinMyGuild();
    if (!mounted) return;
    final provider = context.read<GuildProvider>();
    final reward = int.tryParse('${data?['reward_gold'] ?? data?['rewardGold'] ?? 200}') ?? 200;
    final exp = int.tryParse('${data?['guild_exp_gain'] ?? data?['guildExpGain'] ?? 50}') ?? 50;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: data != null ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          data != null
              ? 'Điểm danh thành công: +$reward vàng, bang hội +$exp EXP'
              : (provider.errorMessage ?? 'Điểm danh thất bại'),
        ),
      ),
    );
  }

  Future<void> _contributeGuild() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10182B),
        title: const Text(
          'Cống hiến bang hội?',
          style: TextStyle(color: Color(0xFFFFE9B0), fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Bạn sẽ dùng 200 vàng để cống hiến cho bang. Mỗi tài khoản chỉ được cống hiến bang hội 1 lần/ngày.',
          style: TextStyle(color: Color(0xFFE9D7AE), height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4A02F)),
            child: const Text('Cống hiến'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final data = await context.read<GuildProvider>().contributeMyGuild();
    if (!mounted) return;
    final provider = context.read<GuildProvider>();
    final cost = int.tryParse('${data?['gold_cost'] ?? data?['goldCost'] ?? 200}') ?? 200;
    final exp = int.tryParse('${data?['guild_exp_gain'] ?? data?['guildExpGain'] ?? 200}') ?? 200;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: data != null ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          data != null
              ? 'Cống hiến thành công: -$cost vàng, bang hội +$exp EXP'
              : (provider.errorMessage ?? 'Cống hiến thất bại'),
        ),
      ),
    );
  }

  Future<void> _leaveGuild() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10182B),
        title: const Text(
          'Thoát bang hội?',
          style: TextStyle(color: Color(0xFFFFE9B0), fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Sau khi thoát bang, bạn sẽ không còn thấy kênh chat của bang này nữa.',
          style: TextStyle(color: Color(0xFFE9D7AE)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB45309)),
            child: const Text('Thoát bang'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    final ok = await context.read<GuildProvider>().leaveMyGuild();
    if (!mounted) return;
    final provider = context.read<GuildProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(ok ? 'Đã thoát bang hội' : (provider.errorMessage ?? 'Thoát bang thất bại')),
      ),
    );
  }

  Future<void> _disbandGuild() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10182B),
        title: const Text(
          'Giải tán bang hội?',
          style: TextStyle(color: Color(0xFFFFE9B0), fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Hành động này sẽ giải tán bang, xoá thành viên và ẩn kênh chat bang.',
          style: TextStyle(color: Color(0xFFE9D7AE)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
            child: const Text('Giải tán'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    final ok = await context.read<GuildProvider>().disbandMyGuild();
    if (!mounted) return;
    final provider = context.read<GuildProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(ok ? 'Đã giải tán bang hội' : (provider.errorMessage ?? 'Giải tán bang thất bại')),
      ),
    );
  }


  Future<void> _changeGuildLogo() async {
    try {
      final guild = context.read<GuildProvider>().myGuild;
      if (guild == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedFile == null || !mounted) return;

      final ok = await context.read<GuildProvider>().updateGuildLogo(
        guildId: guild.id,
        logoFile: File(pickedFile.path),
      );

      if (!mounted) return;

      final provider = context.read<GuildProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
          content: Text(
            ok ? 'Đã cập nhật ảnh bang hội' : (provider.errorMessage ?? 'Cập nhật ảnh bang thất bại'),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text('Lỗi chọn ảnh: $error'),
        ),
      );
    }
  }

  Future<void> _editGuildProfile() async {
    final provider = context.read<GuildProvider>();
    final guild = provider.myGuild ?? provider.guildDetail;
    if (guild == null) return;

    final result = await showDialog<_GuildProfileEditResult>(
      context: context,
      builder: (context) => _GuildProfileEditDialog(guild: guild),
    );

    if (result == null || !mounted) return;

    final ok = await context.read<GuildProvider>().updateMyGuildProfile(
      name: result.name,
      description: result.description,
      announcement: result.announcement,
      memberLimit: result.memberLimit,
      joinRequirementText: result.joinRequirementText,
      joinMinLevel: result.joinMinLevel,
      joinMinPower: result.joinMinPower,
    );

    if (!mounted) return;

    final latestProvider = context.read<GuildProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(ok ? 'Đã cập nhật hồ sơ bang hội' : (latestProvider.errorMessage ?? 'Cập nhật hồ sơ bang thất bại')),
      ),
    );
  }

  Future<void> _changeMemberRole({
    required int memberId,
    required String roleCode,
  }) async {
    final roleLabel = _roleLabel(roleCode);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10182B),
        title: const Text(
          'Đổi chức vụ thành viên?',
          style: TextStyle(color: Color(0xFFFFE9B0), fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Bạn muốn đổi thành viên này thành $roleLabel?',
          style: const TextStyle(color: Color(0xFFE9D7AE), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4A02F)),
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await context.read<GuildProvider>().updateMemberRole(
      memberId: memberId,
      roleCode: roleCode,
    );

    if (!mounted) return;

    final provider = context.read<GuildProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(ok ? 'Đã cập nhật chức vụ thành viên' : (provider.errorMessage ?? 'Cập nhật chức vụ thất bại')),
      ),
    );
  }

  String _roleLabel(String roleCode) {
    switch (roleCode) {
      case 'vice_leader':
        return 'Phó bang';
      case 'elder':
        return 'Trưởng lão';
      case 'member':
        return 'Thành viên';
      default:
        return roleCode;
    }
  }

  List<Guild> _filteredGuilds(List<Guild> guilds) {
    final keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) return guilds;

    return guilds.where((guild) {
      final name = guild.name.toLowerCase();
      final slug = guild.slug.toLowerCase();
      final desc = guild.description?.toLowerCase() ?? '';
      final leader = guild.leaderName?.toLowerCase() ?? '';

      return name.contains(keyword) ||
          slug.contains(keyword) ||
          desc.contains(keyword) ||
          leader.contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final guildProvider = context.watch<GuildProvider>();

    if (guildProvider.isLoading &&
        guildProvider.guilds.isEmpty &&
        guildProvider.myGuild == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF070B14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4A02F)),
        ),
      );
    }

    if (guildProvider.hasJoinedGuild) {
      return Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: RefreshIndicator(
          color: const Color(0xFFD4A02F),
          backgroundColor: const Color(0xFF10182B),
          onRefresh: () => context.read<GuildProvider>().loadGuildHome(),
          child: _MyGuildProfileView(
            guild: guildProvider.myGuild!,
            members: guildProvider.members,
            isLeader: guildProvider.isMyGuildLeader,
            isSubmitting: guildProvider.isSubmitting,
            onCheckin: _checkinGuild,
            onContribute: _contributeGuild,
            onLeave: _leaveGuild,
            onDisband: _disbandGuild,
            onChangeLogo: _changeGuildLogo,
            onEditProfile: _editGuildProfile,
            onChangeMemberRole: _changeMemberRole,
          ),
        ),
      );
    }

    final visibleGuilds = _filteredGuilds(guildProvider.guilds);
    final totalGuilds = guildProvider.guilds.length;
    final strongGuilds = guildProvider.guilds.where((e) => (e.guildPower ?? 0) > 0).length;
    final leaderGuilds = guildProvider.guilds.where((e) => e.hasLeader).length;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: guildProvider.isSubmitting ? null : _openCreateGuildDialog,
        backgroundColor: const Color(0xFFD4A02F),
        foregroundColor: const Color(0xFF211407),
        icon: guildProvider.isSubmitting
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF211407),
          ),
        )
            : const Icon(Icons.add_rounded),
        label: const Text(
          'Tạo bang',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        onRefresh: () => context.read<GuildProvider>().loadGuildHome(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: GuildHeader(
                totalGuilds: totalGuilds,
                strongGuilds: strongGuilds,
                leaderGuilds: leaderGuilds,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: _searchBox(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _sectionHeader(
                  title: 'Danh sách bang hội',
                  action: '${visibleGuilds.length} bang',
                ),
              ),
            ),
            if (guildProvider.errorMessage != null && guildProvider.guilds.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      guildProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE6D4AC),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
            else if (guildProvider.guilds.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: GuildEmptyView(),
                ),
              )
            else if (visibleGuilds.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NoGuildResultView(
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 92),
                  sliver: SliverList.separated(
                    itemCount: visibleGuilds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return GuildListCard(
                        guild: visibleGuilds[index],
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFFD4A02F),
        decoration: InputDecoration(
          hintText: 'Tìm bang, bang chủ, mô tả...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 13.5,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.68),
          ),
          suffixIcon: _searchController.text.trim().isEmpty
              ? const Icon(
            Icons.groups_outlined,
            color: Color(0xFFD4A02F),
          )
              : IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFD4A02F),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String action,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A02F),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: TextStyle(
            color: Colors.white.withOpacity(0.48),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MyGuildProfileView extends StatelessWidget {
  const _MyGuildProfileView({
    required this.guild,
    required this.members,
    required this.isLeader,
    required this.isSubmitting,
    required this.onCheckin,
    required this.onContribute,
    required this.onLeave,
    required this.onDisband,
    required this.onChangeLogo,
    required this.onEditProfile,
    required this.onChangeMemberRole,
  });

  final Guild guild;
  final List<GuildMember> members;
  final bool isLeader;
  final bool isSubmitting;
  final VoidCallback onCheckin;
  final VoidCallback onContribute;
  final VoidCallback onLeave;
  final VoidCallback onDisband;
  final VoidCallback onChangeLogo;
  final VoidCallback onEditProfile;
  final void Function({required int memberId, required String roleCode}) onChangeMemberRole;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _profileHero(context),
        Transform.translate(
          offset: const Offset(0, -22),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
            child: Column(
              children: [
                _GuildCommandPanel(
                  guild: guild,
                  isLeader: isLeader,
                  isSubmitting: isSubmitting,
                  onChangeLogo: onChangeLogo,
                  onEditProfile: onEditProfile,
                ),
                const SizedBox(height: 14),
                _GuildHomeExpCard(guild: guild),
                const SizedBox(height: 14),
                _GuildStoryPanel(guild: guild),
                const SizedBox(height: 14),
                _GuildRequirementPanel(guild: guild),
                const SizedBox(height: 14),
                _GuildMemberPanel(
                  members: members,
                  isLeader: isLeader,
                  isSubmitting: isSubmitting,
                  onChangeMemberRole: onChangeMemberRole,
                ),
                const SizedBox(height: 14),
                _MyGuildActionCard(
                  isLeader: isLeader,
                  isSubmitting: isSubmitting,
                  onCheckin: onCheckin,
                  onContribute: onContribute,
                  onLeave: onLeave,
                  onDisband: onDisband,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileHero(BuildContext context) {
    final memberText = guild.memberText;
    final levelText = 'Lv ${guild.level ?? 1}';
    final powerText = '${guild.guildPower ?? 0} lực chiến';

    return Container(
      constraints: const BoxConstraints(minHeight: 302),
      padding: const EdgeInsets.fromLTRB(18, 46, 18, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF060914),
            Color(0xFF101837),
            Color(0xFF38270C),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -18,
            child: _BlurOrb(
              size: 150,
              color: Color(0xFFD4A02F),
              opacity: 0.22,
            ),
          ),
          Positioned(
            left: -58,
            bottom: -60,
            child: _BlurOrb(
              size: 150,
              color: Color(0xFF6C63FF),
              opacity: 0.16,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Hồ sơ bang hội',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _HeroIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: () => context.read<GuildProvider>().loadGuildHome(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _GuildLogoBadge(guild: guild, isLeader: isLeader, onChangeLogo: onChangeLogo),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F7A3F),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF45FF99).withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF45FF99).withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  guild.displayStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                guild.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFE9B0),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                guild.slug.trim().isEmpty ? 'Tông môn tu luyện' : '@${guild.slug}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _HeroStatPill(
                      icon: Icons.military_tech_rounded,
                      label: levelText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroStatPill(
                      icon: Icons.bolt_rounded,
                      label: powerText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroStatPill(
                      icon: Icons.groups_2_rounded,
                      label: memberText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuildCommandPanel extends StatelessWidget {
  const _GuildCommandPanel({
    required this.guild,
    required this.isLeader,
    required this.isSubmitting,
    required this.onChangeLogo,
    required this.onEditProfile,
  });

  final Guild guild;
  final bool isLeader;
  final bool isSubmitting;
  final VoidCallback onChangeLogo;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return _LuxuryPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.person_rounded,
                  label: 'Bang chủ',
                  value: guild.leaderName ?? 'Không rõ',
                  accentColor: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.volunteer_activism_rounded,
                  label: 'Cống hiến',
                  value: '${guild.contributionPoints ?? 0}',
                  accentColor: const Color(0xFFFF8A8A),
                ),
              ),
            ],
          ),
          if (isLeader) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PremiumSmallButton(
                    icon: Icons.photo_camera_outlined,
                    label: 'Đổi ảnh bang',
                    onTap: isSubmitting ? null : onChangeLogo,
                    backgroundColor: const Color(0xFF1C2440),
                    borderColor: const Color(0xFF8B6A2B),
                    foregroundColor: const Color(0xFFFFD27A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PremiumSmallButton(
                    icon: Icons.edit_note_rounded,
                    label: 'Sửa hồ sơ',
                    onTap: isSubmitting ? null : onEditProfile,
                    backgroundColor: const Color(0xFF6957F6),
                    borderColor: const Color(0xFF8C7BFF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GuildStoryPanel extends StatelessWidget {
  const _GuildStoryPanel({required this.guild});

  final Guild guild;

  @override
  Widget build(BuildContext context) {
    final description = (guild.description ?? '').trim().isNotEmpty
        ? guild.description!.trim()
        : 'Bang hội này hiện chưa có mô tả. Hãy cập nhật giới thiệu để thu hút đạo hữu gia nhập.';
    final announcement = (guild.announcement ?? '').trim();

    return _LuxuryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.auto_stories_rounded, title: 'Đạo thống bang hội'),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: const Color(0xFFE9D7AE).withOpacity(0.86),
              fontSize: 13.5,
              height: 1.48,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (announcement.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2B52), Color(0xFF151D36)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4A5F96)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.campaign_rounded, color: Color(0xFFFFD27A), size: 19),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      announcement,
                      style: const TextStyle(
                        color: Color(0xFFFFE9B0),
                        height: 1.42,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuildRequirementPanel extends StatelessWidget {
  const _GuildRequirementPanel({required this.guild});

  final Guild guild;

  @override
  Widget build(BuildContext context) {
    return _LuxuryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.verified_user_outlined, title: 'Yêu cầu nhập bang'),
          const SizedBox(height: 12),
          Text(
            guild.displayJoinRequirement,
            style: TextStyle(
              color: const Color(0xFFE9D7AE).withOpacity(0.84),
              height: 1.5,
              fontSize: 13.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.lock_open_rounded, label: guild.joinRequirementSummary),
              _InfoChip(icon: Icons.groups_rounded, label: 'Tối đa ${guild.memberLimit ?? 30} thành viên'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuildMemberPanel extends StatelessWidget {
  const _GuildMemberPanel({
    required this.members,
    required this.isLeader,
    required this.isSubmitting,
    required this.onChangeMemberRole,
  });

  final List<GuildMember> members;
  final bool isLeader;
  final bool isSubmitting;
  final void Function({required int memberId, required String roleCode}) onChangeMemberRole;

  @override
  Widget build(BuildContext context) {
    return _LuxuryPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Row(
              children: [
                const Expanded(
                  child: _PanelTitle(icon: Icons.people_alt_rounded, title: 'Đệ tử trong bang'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2540),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF3E527D)),
                  ),
                  child: Text(
                    '${members.length} người',
                    style: const TextStyle(
                      color: Color(0xFFFFD27A),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Text(
                'Chưa có dữ liệu thành viên.',
                style: TextStyle(color: const Color(0xFFE9D7AE).withOpacity(0.72)),
              ),
            )
          else
            Column(
              children: members
                  .map(
                    (member) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GuildMemberTile(
                    member: member,
                    canManageRole: isLeader,
                    isSubmitting: isSubmitting,
                    onChangeRole: (roleCode) => onChangeMemberRole(
                      memberId: member.id,
                      roleCode: roleCode,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _GuildHomeExpCard extends StatelessWidget {
  const _GuildHomeExpCard({required this.guild});

  final Guild guild;

  @override
  Widget build(BuildContext context) {
    return _LuxuryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _PanelTitle(icon: Icons.auto_graph_rounded, title: 'Tu vi bang hội'),
              ),
              _InfoChip(icon: Icons.star_rounded, label: 'Cấp ${guild.level ?? 1}'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  guild.expText,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${(guild.expProgress * 100).round()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.66),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GradientProgressBar(value: guild.expProgress),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.bolt_rounded,
                  label: 'Chiến lực',
                  value: '${guild.guildPower ?? 0}',
                  accentColor: const Color(0xFF8FB0FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.workspace_premium_rounded,
                  label: 'EXP còn thiếu',
                  value: '${((guild.safeNextLevelExp - guild.safeCurrentExp).clamp(0, guild.safeNextLevelExp))}',
                  accentColor: const Color(0xFFFFD27A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Điểm danh và cống hiến giúp bang hội tích lũy EXP, mở rộng thế lực và tăng uy danh.',
            style: TextStyle(
              color: const Color(0xFFE9D7AE).withOpacity(0.68),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyGuildActionCard extends StatelessWidget {
  const _MyGuildActionCard({
    required this.isLeader,
    required this.isSubmitting,
    required this.onCheckin,
    required this.onContribute,
    required this.onLeave,
    required this.onDisband,
  });

  final bool isLeader;
  final bool isSubmitting;
  final VoidCallback onCheckin;
  final VoidCallback onContribute;
  final VoidCallback onLeave;
  final VoidCallback onDisband;

  @override
  Widget build(BuildContext context) {
    return _LuxuryPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.local_fire_department_rounded, title: 'Hoạt động bang hội'),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _ActionGemButton(
                  icon: Icons.event_available_rounded,
                  title: 'Điểm danh',
                  subtitle: '+200 vàng • +50 EXP',
                  color: const Color(0xFFD4A02F),
                  foregroundColor: const Color(0xFF211407),
                  onTap: isSubmitting ? null : onCheckin,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionGemButton(
                  icon: Icons.volunteer_activism_rounded,
                  title: 'Cống hiến',
                  subtitle: '200 vàng • +200 EXP',
                  color: const Color(0xFF5B7CFA),
                  foregroundColor: Colors.white,
                  onTap: isSubmitting ? null : onContribute,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isSubmitting ? null : onLeave,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFD27A),
              side: const BorderSide(color: Color(0xFF8B6A2B)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Thoát bang',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          if (isLeader) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : onDisband,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF8A8A),
                side: const BorderSide(color: Color(0xFFFF6B6B)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text(
                'Giải tán bang',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LuxuryPanel extends StatelessWidget {
  const _LuxuryPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10182B), Color(0xFF111C35)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF263E68)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A02F).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF8B6A2B)),
          ),
          child: Icon(icon, color: const Color(0xFFFFD27A), size: 16),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFE9B0),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GuildLogoBadge extends StatelessWidget {
  const _GuildLogoBadge({
    required this.guild,
    required this.isLeader,
    required this.onChangeLogo,
  });

  final Guild guild;
  final bool isLeader;
  final VoidCallback onChangeLogo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLeader ? onChangeLogo : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD27A), Color(0xFF6C63FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A02F).withOpacity(0.28),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 106,
            height: 106,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF090D19),
            ),
            child: ClipOval(
              child: guild.hasLogo
                  ? Image.network(
                guild.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.groups_3_rounded,
                  color: Color(0xFFFFD27A),
                  size: 48,
                ),
              )
                  : const Icon(
                Icons.groups_3_rounded,
                color: Color(0xFFFFD27A),
                size: 50,
              ),
            ),
          ),
          if (isLeader)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A02F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF070B14), width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF211407), size: 17),
              ),
            ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFFD27A), size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121B31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.52),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumSmallButton extends StatelessWidget {
  const _PremiumSmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          decoration: BoxDecoration(
            color: onTap == null ? backgroundColor.withOpacity(0.45) : backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2540),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF33446B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD27A), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFD27A),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  const _GradientProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0).toDouble();

    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2540),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF30415F)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: safeValue,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD4A02F), Color(0xFFFFD27A), Color(0xFF70E1A1)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGemButton extends StatelessWidget {
  const _ActionGemButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(onTap == null ? 0.35 : 1),
                color.withOpacity(onTap == null ? 0.22 : 0.78),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: onTap == null
                ? []
                : [
              BoxShadow(
                color: color.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: foregroundColor, size: 22),
              const SizedBox(height: 16),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor.withOpacity(0.76),
                  fontWeight: FontWeight.w700,
                  fontSize: 10.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuildProfileEditResult {
  const _GuildProfileEditResult({
    required this.name,
    this.description,
    this.announcement,
    this.memberLimit,
    this.joinRequirementText,
    this.joinMinLevel,
    this.joinMinPower,
  });

  final String name;
  final String? description;
  final String? announcement;
  final int? memberLimit;
  final String? joinRequirementText;
  final int? joinMinLevel;
  final int? joinMinPower;
}

class _GuildProfileEditDialog extends StatefulWidget {
  const _GuildProfileEditDialog({required this.guild});

  final Guild guild;

  @override
  State<_GuildProfileEditDialog> createState() => _GuildProfileEditDialogState();
}

class _GuildProfileEditDialogState extends State<_GuildProfileEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _announcementController;
  late final TextEditingController _memberLimitController;
  late final TextEditingController _requirementController;
  late final TextEditingController _minLevelController;
  late final TextEditingController _minPowerController;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final guild = widget.guild;
    _nameController = TextEditingController(text: guild.name);
    _descriptionController = TextEditingController(text: guild.description ?? '');
    _announcementController = TextEditingController(text: guild.announcement ?? '');
    _memberLimitController = TextEditingController(text: '${guild.memberLimit ?? 30}');
    _requirementController = TextEditingController(text: guild.joinRequirementText ?? '');
    _minLevelController = TextEditingController(text: '${guild.joinMinLevel ?? 1}');
    _minPowerController = TextEditingController(text: '${guild.joinMinPower ?? 0}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _announcementController.dispose();
    _memberLimitController.dispose();
    _requirementController.dispose();
    _minLevelController.dispose();
    _minPowerController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final memberLimit = int.tryParse(_memberLimitController.text.trim());
    final minLevel = int.tryParse(_minLevelController.text.trim());
    final minPower = int.tryParse(_minPowerController.text.trim());

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Tên bang hội không được để trống');
      return;
    }

    if (memberLimit == null || memberLimit <= 0) {
      setState(() => _errorMessage = 'Giới hạn thành viên phải lớn hơn 0');
      return;
    }

    if (minLevel == null || minLevel < 1) {
      setState(() => _errorMessage = 'Cấp yêu cầu phải từ 1 trở lên');
      return;
    }

    if (minPower == null || minPower < 0) {
      setState(() => _errorMessage = 'Chiến lực yêu cầu không hợp lệ');
      return;
    }

    Navigator.of(context).pop(
      _GuildProfileEditResult(
        name: name,
        description: _nullIfBlank(_descriptionController.text),
        announcement: _nullIfBlank(_announcementController.text),
        memberLimit: memberLimit,
        joinRequirementText: _nullIfBlank(_requirementController.text),
        joinMinLevel: minLevel,
        joinMinPower: minPower,
      ),
    );
  }

  String? _nullIfBlank(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF10182B),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      title: const Text(
        'Sửa hồ sơ bang hội',
        style: TextStyle(color: Color(0xFFFFE9B0), fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GuildEditField(controller: _nameController, label: 'Tên bang hội'),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF17213A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF33446B)),
                ),
                child: const Text(
                  'Ảnh bang hội được đổi trực tiếp bằng nút “Đổi ảnh bang” ở phần thông tin chính.',
                  style: TextStyle(color: Color(0xFFD8C08A), height: 1.35, fontSize: 12.5),
                ),
              ),
              _GuildEditField(
                controller: _descriptionController,
                label: 'Giới thiệu bang hội',
                maxLines: 3,
              ),
              _GuildEditField(
                controller: _announcementController,
                label: 'Thông báo bang',
                maxLines: 3,
              ),
              _GuildEditField(
                controller: _requirementController,
                label: 'Nội dung yêu cầu vào bang',
                maxLines: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: _GuildEditField(
                      controller: _minLevelController,
                      label: 'Cấp tối thiểu',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GuildEditField(
                      controller: _minPowerController,
                      label: 'Chiến lực tối thiểu',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _GuildEditField(
                controller: _memberLimitController,
                label: 'Giới hạn thành viên',
                keyboardType: TextInputType.number,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFFF8A8A), fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4A02F)),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _GuildEditField extends StatelessWidget {
  const _GuildEditField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFD8C08A)),
          filled: true,
          fillColor: const Color(0xFF17213A),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF33446B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD4A02F)),
          ),
        ),
      ),
    );
  }
}

class _NoGuildResultView extends StatelessWidget {
  const _NoGuildResultView({
    required this.onClear,
  });

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Color(0xFFFFD27A),
              size: 46,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không tìm thấy bang hội',
              style: TextStyle(
                color: Color(0xFFFFE9B0),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Thử đổi từ khóa hoặc bỏ nội dung tìm kiếm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.52),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Xóa tìm kiếm'),
            ),
          ],
        ),
      ),
    );
  }
}
