import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GuildProvider>().loadGuilds();
    });
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

  @override
  Widget build(BuildContext context) {
    final guildProvider = context.watch<GuildProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: guildProvider.isSubmitting ? null : _openCreateGuildDialog,
        backgroundColor: const Color(0xFFC7962F),
        foregroundColor: const Color(0xFF24170B),
        icon: guildProvider.isSubmitting
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF24170B),
          ),
        )
            : const Icon(Icons.add),
        label: const Text(
          'Tạo Guild',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: () => context.read<GuildProvider>().loadGuilds(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            const GuildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _GuildTipCard(
                text:
                'Bạn có thể tạo bang phái mới hoặc gửi đơn xin gia nhập bang phái hiện có. Việc duyệt tham gia sẽ do admin hoặc chủ guild xử lý.',
              ),
            ),
            if (guildProvider.isLoading && guildProvider.guilds.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFC7962F),
                  ),
                ),
              )
            else if (guildProvider.errorMessage != null &&
                guildProvider.guilds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: GuildEmptyView(),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: guildProvider.guilds
                        .map(
                          (guild) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GuildListCard(guild: guild),
                      ),
                    )
                        .toList(),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _GuildTipCard extends StatelessWidget {
  const _GuildTipCard({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE0B85C),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE8D7B3),
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}