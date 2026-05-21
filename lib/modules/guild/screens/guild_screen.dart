import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/guild.dart';
import '../provider/guild_provider.dart';
import '../widgets/create_guild_dialog.dart';
import '../widgets/guild_empty_view.dart';
import '../widgets/guild_header.dart';
import '../widgets/guild_list_card.dart';
import '../widgets/guild_member_tile.dart';
import '../widgets/guild_section_card.dart';
import '../widgets/guild_stat_card.dart';
import 'guild_detail_screen.dart';

class GuildScreen extends StatefulWidget {
  const GuildScreen({super.key});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  final TextEditingController _searchController = TextEditingController();

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
            onOpenDetail: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GuildDetailScreen(guildId: guildProvider.myGuild!.id),
                ),
              );
            },
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
    required this.onOpenDetail,
  });

  final Guild guild;
  final List members;
  final bool isLeader;
  final bool isSubmitting;
  final VoidCallback onCheckin;
  final VoidCallback onContribute;
  final VoidCallback onLeave;
  final VoidCallback onDisband;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      children: [
        _profileHeader(context),
        const SizedBox(height: 14),
        GuildSectionCard(
          title: 'Hồ sơ bang hội',
          icon: Icons.account_balance_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (guild.description ?? '').trim().isNotEmpty
                    ? guild.description!
                    : 'Bang hội này hiện chưa có mô tả.',
                style: TextStyle(
                  color: const Color(0xFFE9D7AE).withOpacity(0.78),
                  fontSize: 13.5,
                  height: 1.48,
                ),
              ),
              if ((guild.announcement ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2136),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF314263)),
                  ),
                  child: Text(
                    guild.announcement!,
                    style: const TextStyle(
                      color: Color(0xFFFFE9B0),
                      fontWeight: FontWeight.w700,
                      height: 1.42,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            GuildStatCard(
              icon: Icons.star_outline_rounded,
              title: 'Cấp bang',
              value: '${guild.level ?? 1}',
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
        _GuildHomeExpCard(guild: guild),
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
          title: 'Thành viên trong bang',
          icon: Icons.people_alt_rounded,
          child: members.isEmpty
              ? Text(
            'Chưa có dữ liệu thành viên.',
            style: TextStyle(
              color: const Color(0xFFE9D7AE).withOpacity(0.72),
            ),
          )
              : Column(
            children: members
                .map((e) => GuildMemberTile(member: e))
                .toList(),
          ),
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
    );
  }

  Widget _profileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF17203A),
            Color(0xFF10182B),
            Color(0xFF2A1F10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3E527D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1020),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD4A02F), width: 1.2),
                ),
                child: guild.hasLogo
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: Image.network(guild.logoUrl!, fit: BoxFit.cover),
                )
                    : const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFFFFD27A),
                  size: 38,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bang hội của bạn',
                      style: TextStyle(
                        color: Color(0xFF8FB0FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guild.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFE9B0),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bang chủ: ${guild.leaderName ?? 'Không rõ'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: onOpenDetail,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A02F),
                foregroundColor: const Color(0xFF211407),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 19),
              label: const Text(
                'Xem chi tiết bang hội',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
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
    return GuildSectionCard(
      title: 'EXP bang hội',
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
              value: guild.expProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFF1B2540),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4A02F)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Điểm danh và cống hiến giúp bang tăng EXP để lên cấp.',
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
    return GuildSectionCard(
      title: 'Hoạt động bang hội',
      icon: Icons.local_activity_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: isSubmitting ? null : onCheckin,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4A02F),
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
