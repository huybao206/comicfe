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
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A07),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chi tiết Guild',
          style: TextStyle(
            color: Color(0xFFF8E6B5),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (guildProvider.isLoading && guild == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC7962F),
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              GuildDetailHeader(guild: guild),
              const SizedBox(height: 16),
              GuildSectionCard(
                title: 'Giới thiệu',
                child: Text(
                  (guild.description ?? '').trim().isNotEmpty
                      ? guild.description!
                      : 'Guild này hiện chưa có mô tả.',
                  style: const TextStyle(
                    color: Color(0xFFE8D7B3),
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GuildStatCard(
                icon: Icons.person_outline_rounded,
                title: 'Leader',
                value: guild.leaderName ?? 'Không rõ',
              ),
              const SizedBox(height: 12),
              GuildStatCard(
                icon: Icons.shield_outlined,
                title: 'Status',
                value: guild.guildStatus ?? 'Không rõ',
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: guildProvider.isSubmitting ? null : _joinGuild,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC7962F),
                  foregroundColor: const Color(0xFF24170B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.group_add_outlined),
                label: const Text(
                  'Gửi đơn xin vào guild',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF17110C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF735624)),
                ),
                child: const Text(
                  'Yêu cầu tham gia sau khi gửi sẽ chờ admin hoặc chủ guild duyệt.',
                  style: TextStyle(
                    color: Color(0xFFE8D7B3),
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GuildSectionCard(
                title: 'Thành viên',
                child: guildProvider.members.isEmpty
                    ? const Text(
                  'Chưa có dữ liệu thành viên.',
                  style: TextStyle(color: Color(0xFFE8D7B3)),
                )
                    : Column(
                  children: guildProvider.members
                      .map((e) => GuildMemberTile(member: e))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}