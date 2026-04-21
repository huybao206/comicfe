import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/comic/screens/comic_list_screen.dart';
import '../modules/economy/shop/screen/shop_screen.dart';
import '../modules/game/afk/screen/afk_screen.dart';
import '../modules/guild/screens/guild_detail_screen.dart';
import '../modules/notification/provider/notification_provider.dart';
import '../modules/notification/screens/notification_screen.dart';
import '../modules/ranking/screens/ranking_screen.dart';
import '../modules/user/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final pages = const [
    ComicListScreen(),
    ShopScreen(),
    GuildScreen(),
    RankingScreen(),
    AfkScreen(),
    ProfileScreen(),
  ];

  final titles = const [
    'Truyện',
    'Shop',
    'Guild',
    'BXH',
    'AFK',
    'Tôi',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  void _changePage(int index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.of(context).pop();
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
      ),
    );

    if (!mounted) return;
    context.read<NotificationProvider>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1320),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1320),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          titles[currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final count = provider.unreadCount;

              return IconButton(
                tooltip: 'Thông báo',
                onPressed: _openNotifications,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    if (count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE64545),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF0E1320),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF151B2D),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFF0E1320),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFF5B8CFF),
                      size: 42,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Comic Cultivation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tu tiên đọc truyện',
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              _drawerItem(
                index: 0,
                icon: Icons.menu_book_outlined,
                title: 'Truyện',
              ),
              _drawerItem(
                index: 1,
                icon: Icons.storefront_outlined,
                title: 'Shop',
              ),
              _drawerItem(
                index: 2,
                icon: Icons.groups_outlined,
                title: 'Guild',
              ),
              _drawerItem(
                index: 3,
                icon: Icons.emoji_events_outlined,
                title: 'Bảng xếp hạng',
              ),
              _drawerItem(
                index: 4,
                icon: Icons.bolt_outlined,
                title: 'AFK',
              ),
              _drawerItem(
                index: 5,
                icon: Icons.person_outline,
                title: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
    );
  }

  Widget _drawerItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final selected = currentIndex == index;

    return ListTile(
      selected: selected,
      selectedTileColor: const Color(0xFF2848A9).withOpacity(0.35),
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF8FB0FF) : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () => _changePage(index),
    );
  }
}