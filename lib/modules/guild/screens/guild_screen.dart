import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/guild.dart';
import '../provider/guild_provider.dart';
import '../widgets/create_guild_dialog.dart';
import '../widgets/guild_empty_view.dart';
import '../widgets/guild_header.dart';
import '../widgets/guild_list_card.dart';

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
      context.read<GuildProvider>().loadGuilds();
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
          content: Text('Tạo guild thành công'),
        ),
      );

      await provider.loadGuilds();
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
    final visibleGuilds = _filteredGuilds(guildProvider.guilds);

    final totalGuilds = guildProvider.guilds.length;
    final strongGuilds =
        guildProvider.guilds.where((e) => (e.guildPower ?? 0) > 0).length;
    final leaderGuilds =
        guildProvider.guilds.where((e) => e.hasLeader).length;

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
          'Tạo Guild',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        onRefresh: () => context.read<GuildProvider>().loadGuilds(),
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
                  title: 'Danh sách tông môn',
                  action: '${visibleGuilds.length} guild',
                ),
              ),
            ),
            if (guildProvider.isLoading && guildProvider.guilds.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4A02F),
                  ),
                ),
              )
            else if (guildProvider.errorMessage != null &&
                guildProvider.guilds.isEmpty)
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
          hintText: 'Tìm guild, leader, mô tả...',
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
              'Không tìm thấy guild',
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
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onClear,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A02F),
                foregroundColor: const Color(0xFF211407),
              ),
              child: const Text(
                'Xóa tìm kiếm',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}