import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/guild_provider.dart';
import '../widgets/guild_detail_header.dart';
import '../widgets/guild_member_tile.dart';
import '../widgets/guild_section_card.dart';
import '../widgets/guild_stat_card.dart';

class GuildDetailScreen extends StatefulWidget {
  const GuildDetailScreen({
    super.key,
    required this.guildId,
  });

  final int guildId;

  @override
  State<GuildDetailScreen> createState() => _GuildDetailScreenState();
}

class _GuildDetailScreenState extends State<GuildDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<GuildProvider>().loadGuildDetailFull(widget.guildId);
    });
  }

  Future<void> _joinGuild() async {
    final ok = await context.read<GuildProvider>().joinGuild(widget.guildId);

    if (!mounted) return;

    final provider = context.read<GuildProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Đã gửi yêu cầu tham gia bang. Vui lòng chờ bang chủ duyệt.'
              : (provider.errorMessage ?? 'Gửi yêu cầu thất bại'),
        ),
      ),
    );
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
      logoUrl: result.logoUrl,
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
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

    if (ok && mounted) Navigator.of(context).pop();
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
          'Hành động này sẽ xoá hẳn bang hội khỏi hệ thống, xoá thành viên và xoá kênh chat bang. Bạn chắc chắn muốn tiếp tục?',
          style: TextStyle(color: Color(0xFFE9D7AE), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
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
        content: Text(ok ? 'Đã xoá bang hội khỏi hệ thống' : (provider.errorMessage ?? 'Giải tán bang thất bại')),
      ),
    );

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final guildProvider = context.watch<GuildProvider>();
    final guild = guildProvider.guildDetail;
    final isMyGuild = guild != null && guildProvider.isCurrentUserGuild(guild.id);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Builder(
        builder: (_) {
          if (guildProvider.isLoading && guild == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4A02F),
              ),
            );
          }

          if (guild == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  guildProvider.errorMessage ?? 'Không có dữ liệu bang hội',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE6D4AC),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 330,
                    pinned: true,
                    backgroundColor: const Color(0xFF070B14),
                    surfaceTintColor: Colors.transparent,
                    iconTheme: const IconThemeData(
                      color: Color(0xFFFFE9B0),
                    ),
                    title: Text(
                      isMyGuild ? 'Hồ sơ bang hội' : 'Chi tiết bang hội',
                      style: const TextStyle(
                        color: Color(0xFFFFE9B0),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: GuildDetailHeader(guild: guild),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(14, 16, 14, isMyGuild ? 24 : 112),
                      child: Column(
                        children: [
                          GuildSectionCard(
                            title: 'Giới thiệu bang hội',
                            icon: Icons.menu_book_outlined,
                            child: Text(
                              (guild.description ?? '').trim().isNotEmpty
                                  ? guild.description!
                                  : 'Bang hội này hiện chưa có mô tả.',
                              style: TextStyle(
                                color: const Color(0xFFE9D7AE).withOpacity(0.74),
                                height: 1.55,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          if ((guild.announcement ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 14),
                            GuildSectionCard(
                              title: 'Thông báo bang',
                              icon: Icons.campaign_outlined,
                              child: Text(
                                guild.announcement!,
                                style: TextStyle(
                                  color: const Color(0xFFE9D7AE).withOpacity(0.82),
                                  height: 1.55,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          GuildSectionCard(
                            title: 'Yêu cầu vào bang',
                            icon: Icons.verified_user_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  guild.displayJoinRequirement,
                                  style: TextStyle(
                                    color: const Color(0xFFE9D7AE).withOpacity(0.82),
                                    height: 1.5,
                                    fontSize: 13.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B2540),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: const Color(0xFF33446B)),
                                  ),
                                  child: Text(
                                    guild.joinRequirementSummary,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD27A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              GuildStatCard(
                                icon: Icons.person_outline_rounded,
                                title: 'Bang chủ',
                                value: guild.leaderName ?? 'Không rõ',
                                accentColor: const Color(0xFF4ADE80),
                              ),
                              const SizedBox(width: 10),
                              GuildStatCard(
                                icon: Icons.shield_outlined,
                                title: 'Trạng thái',
                                value: guild.displayStatus,
                                accentColor: const Color(0xFFFFD27A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              GuildStatCard(
                                icon: Icons.star_outline_rounded,
                                title: 'Cấp bang',
                                value: '${guild.level ?? 0}',
                                accentColor: const Color(0xFFFFD27A),
                              ),
                              const SizedBox(width: 10),
                              GuildStatCard(
                                icon: Icons.groups_rounded,
                                title: 'Thành viên',
                                value: guild.memberText,
                                accentColor: const Color(0xFF4ADE80),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _GuildExpProgressCard(guild: guild),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              GuildStatCard(
                                icon: Icons.bolt_outlined,
                                title: 'Chiến lực',
                                value: '${guild.guildPower ?? 0}',
                                accentColor: const Color(0xFF8FB0FF),
                              ),
                              const SizedBox(width: 10),
                              GuildStatCard(
                                icon: Icons.volunteer_activism_outlined,
                                title: 'Cống hiến',
                                value: '${guild.contributionPoints ?? 0}',
                                accentColor: const Color(0xFFFF8A8A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GuildSectionCard(
                            title: 'Thành viên',
                            icon: Icons.groups_rounded,
                            child: guildProvider.members.isEmpty
                                ? Text(
                              'Chưa có dữ liệu thành viên.',
                              style: TextStyle(
                                color: const Color(0xFFE9D7AE).withOpacity(0.72),
                              ),
                            )
                                : Column(
                              children: guildProvider.members
                                  .map(
                                    (e) => GuildMemberTile(
                                  member: e,
                                  canManageRole: guildProvider.isMyGuildLeader,
                                  isSubmitting: guildProvider.isSubmitting,
                                  onChangeRole: (roleCode) => _changeMemberRole(
                                    memberId: e.id,
                                    roleCode: roleCode,
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                          if (isMyGuild) ...[
                            const SizedBox(height: 14),
                            _GuildActionSection(
                              isLeader: guildProvider.isMyGuildLeader,
                              isSubmitting: guildProvider.isSubmitting,
                              onEditProfile: _editGuildProfile,
                              onCheckin: _checkinGuild,
                              onContribute: _contributeGuild,
                              onLeave: _leaveGuild,
                              onDisband: _disbandGuild,
                            ),
                          ],
                          if (!isMyGuild) ...[
                            const SizedBox(height: 14),
                            GuildSectionCard(
                              title: 'Cơ chế tham gia',
                              icon: Icons.info_outline_rounded,
                              child: Text(
                                'Yêu cầu tham gia sau khi gửi sẽ chờ bang chủ hoặc người có quyền duyệt. Khi được chấp nhận, bạn mới chính thức trở thành thành viên.',
                                style: TextStyle(
                                  color: const Color(0xFFE9D7AE).withOpacity(0.72),
                                  height: 1.52,
                                  fontSize: 13.2,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isMyGuild)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _JoinGuildBar(
                    isSubmitting: guildProvider.isSubmitting,
                    onJoin: _joinGuild,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}


class _GuildExpProgressCard extends StatelessWidget {
  const _GuildExpProgressCard({required this.guild});

  final dynamic guild;

  @override
  Widget build(BuildContext context) {
    final progress = guild.expProgress as double;

    return GuildSectionCard(
      title: 'Kinh nghiệm bang hội',
      icon: Icons.auto_graph_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cấp ${guild.level ?? 1}',
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                guild.expText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF1B2540),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4A02F)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Điểm danh và cống hiến sẽ cộng EXP để nâng cấp bang hội.',
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



class _GuildProfileEditResult {
  const _GuildProfileEditResult({
    required this.name,
    this.logoUrl,
    this.description,
    this.announcement,
    this.memberLimit,
    this.joinRequirementText,
    this.joinMinLevel,
    this.joinMinPower,
  });

  final String name;
  final String? logoUrl;
  final String? description;
  final String? announcement;
  final int? memberLimit;
  final String? joinRequirementText;
  final int? joinMinLevel;
  final int? joinMinPower;
}

class _GuildProfileEditDialog extends StatefulWidget {
  const _GuildProfileEditDialog({required this.guild});

  final dynamic guild;

  @override
  State<_GuildProfileEditDialog> createState() => _GuildProfileEditDialogState();
}

class _GuildProfileEditDialogState extends State<_GuildProfileEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _logoController;
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
    _nameController = TextEditingController(text: '${guild.name ?? ''}');
    _logoController = TextEditingController(text: '${guild.logoUrl ?? ''}');
    _descriptionController = TextEditingController(text: '${guild.description ?? ''}');
    _announcementController = TextEditingController(text: '${guild.announcement ?? ''}');
    _memberLimitController = TextEditingController(text: '${guild.memberLimit ?? 30}');
    _requirementController = TextEditingController(text: '${guild.joinRequirementText ?? ''}');
    _minLevelController = TextEditingController(text: '${guild.joinMinLevel ?? 1}');
    _minPowerController = TextEditingController(text: '${guild.joinMinPower ?? 0}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
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
        logoUrl: _nullIfBlank(_logoController.text),
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
              _GuildEditField(controller: _logoController, label: 'Avatar/Logo bang URL'),
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

class _GuildActionSection extends StatelessWidget {
  const _GuildActionSection({
    required this.isLeader,
    required this.isSubmitting,
    required this.onEditProfile,
    required this.onCheckin,
    required this.onContribute,
    required this.onLeave,
    required this.onDisband,
  });

  final bool isLeader;
  final bool isSubmitting;
  final VoidCallback onEditProfile;
  final VoidCallback onCheckin;
  final VoidCallback onContribute;
  final VoidCallback onLeave;
  final VoidCallback onDisband;

  @override
  Widget build(BuildContext context) {
    return GuildSectionCard(
      title: 'Hoạt động bang hội',
      icon: Icons.local_activity_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLeader) ...[
            FilledButton.icon(
              onPressed: isSubmitting ? null : onEditProfile,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                disabledBackgroundColor: const Color(0xFF363154),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text(
                'Sửa hồ sơ và yêu cầu vào bang',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),
          ],
          FilledButton.icon(
            onPressed: isSubmitting ? null : onCheckin,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4A02F),
              disabledBackgroundColor: const Color(0xFF514225),
              foregroundColor: const Color(0xFF211407),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.event_available_rounded),
            label: const Text(
              'Điểm danh +200 vàng, +50 EXP',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: isSubmitting ? null : onContribute,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5B7CFA),
              disabledBackgroundColor: const Color(0xFF323A62),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.volunteer_activism_rounded),
            label: const Text(
              'Cống hiến 200 vàng +200 EXP',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isSubmitting ? null : onLeave,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFD27A),
              side: const BorderSide(color: Color(0xFF8B6A2B)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _JoinGuildBar extends StatelessWidget {
  const _JoinGuildBar({
    required this.isSubmitting,
    required this.onJoin,
  });

  final bool isSubmitting;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        border: const Border(
          top: BorderSide(color: Color(0xFF1E2A44)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.32),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF11182A),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFF263756)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFFFFD27A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tham gia cần được duyệt',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFFFE9B0).withOpacity(0.92),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: isSubmitting ? null : onJoin,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A02F),
                  disabledBackgroundColor: const Color(0xFF514225),
                  foregroundColor: const Color(0xFF211407),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF211407),
                  ),
                )
                    : const Row(
                  children: [
                    Icon(Icons.group_add_rounded, size: 19),
                    SizedBox(width: 7),
                    Text(
                      'Xin vào',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
