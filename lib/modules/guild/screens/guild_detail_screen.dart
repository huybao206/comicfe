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
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Đã gửi yêu cầu tham gia guild. Vui lòng chờ admin duyệt.'
              : (provider.errorMessage ?? 'Gửi yêu cầu thất bại'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guildProvider = context.watch<GuildProvider>();
    final guild = guildProvider.guildDetail;

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
                  guildProvider.errorMessage ?? 'Không có dữ liệu guild',
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
                    title: const Text(
                      'Chi tiết Guild',
                      style: TextStyle(
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
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 112),
                      child: Column(
                        children: [
                          GuildSectionCard(
                            title: 'Giới thiệu tông môn',
                            icon: Icons.menu_book_outlined,
                            child: Text(
                              (guild.description ?? '').trim().isNotEmpty
                                  ? guild.description!
                                  : 'Guild này hiện chưa có mô tả.',
                              style: TextStyle(
                                color: const Color(0xFFE9D7AE)
                                    .withOpacity(0.74),
                                height: 1.55,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              GuildStatCard(
                                icon: Icons.person_outline_rounded,
                                title: 'Leader',
                                value: guild.leaderName ?? 'Không rõ',
                                accentColor: const Color(0xFF4ADE80),
                              ),
                              const SizedBox(width: 10),
                              GuildStatCard(
                                icon: Icons.shield_outlined,
                                title: 'Status',
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
                                title: 'Level',
                                value: '${guild.level ?? 0}',
                                accentColor: const Color(0xFFFFD27A),
                              ),
                              const SizedBox(width: 10),
                              GuildStatCard(
                                icon: Icons.bolt_outlined,
                                title: 'Power',
                                value: '${guild.guildPower ?? 0}',
                                accentColor: const Color(0xFF8FB0FF),
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
                                color: const Color(0xFFE9D7AE)
                                    .withOpacity(0.72),
                              ),
                            )
                                : Column(
                              children: guildProvider.members
                                  .map(
                                    (e) => GuildMemberTile(member: e),
                              )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          GuildSectionCard(
                            title: 'Cơ chế tham gia',
                            icon: Icons.info_outline_rounded,
                            child: Text(
                              'Yêu cầu tham gia sau khi gửi sẽ chờ admin hoặc chủ guild duyệt. Khi được chấp nhận, bạn mới chính thức trở thành thành viên.',
                              style: TextStyle(
                                color: const Color(0xFFE9D7AE)
                                    .withOpacity(0.72),
                                height: 1.52,
                                fontSize: 13.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                          color: const Color(0xFFFFE9B0)
                              .withOpacity(0.92),
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