import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/guild_provider.dart';
import '../widgets/guild_detail_header.dart';
import '../widgets/guild_donation_tile.dart';
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

  Future<void> _showDonateDialog() async {
    final pointController = TextEditingController(text: '10');

    final points = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15110C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8B6A2B), width: 1.2),
          ),
          title: const Text(
            'Donate Guild',
            style: TextStyle(
              color: Color(0xFFF6E7BE),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: pointController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Contribution points',
              labelStyle: const TextStyle(color: Color(0xFFD8C08A)),
              filled: true,
              fillColor: const Color(0xFF21170F),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF6E5423)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE0B85C)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  int.tryParse(pointController.text.trim()) ?? 0,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC7962F),
                foregroundColor: const Color(0xFF24170B),
              ),
              child: const Text(
                'Donate',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    pointController.dispose();

    if (points == null || points <= 0) return;

    final ok = await context.read<GuildProvider>().donateGuild(
      guildId: widget.guildId,
      contributionPoints: points,
    );

    if (!mounted) return;

    final provider = context.read<GuildProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Donate thành công'
              : (provider.errorMessage ?? 'Donate thất bại'),
        ),
      ),
    );

    if (ok) {
      context.read<GuildProvider>().loadGuildDetailFull(widget.guildId);
    }
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: guildProvider.isSubmitting ? null : _showDonateDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8D7B3),
                  side: const BorderSide(color: Color(0xFF735624)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text(
                  'Donate guild',
                  style: TextStyle(fontWeight: FontWeight.w800),
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
              const SizedBox(height: 16),
              GuildSectionCard(
                title: 'Yêu cầu tham gia',
                child: const Text(
                  'Danh sách yêu cầu tham gia hiện được quản lý ở phía admin.',
                  style: TextStyle(color: Color(0xFFE8D7B3)),
                ),
              ),
              const SizedBox(height: 16),
              GuildSectionCard(
                title: 'Lịch sử donate',
                child: guildProvider.donations.isEmpty
                    ? const Text(
                  'Chưa có lịch sử donate.',
                  style: TextStyle(color: Color(0xFFE8D7B3)),
                )
                    : Column(
                  children: guildProvider.donations
                      .map((e) => GuildDonationTile(donation: e))
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