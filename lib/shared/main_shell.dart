import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/chat/screens/chat_room_list_screen.dart';
import '../modules/comic/screens/comic_list_screen.dart';
import '../modules/cultivation/screens/cultivation_screen.dart';
import '../modules/economy/shop/screen/shop_screen.dart';
import '../modules/game/afk/screen/afk_screen.dart';
import '../modules/mission/screens/mission_screen.dart';
import '../modules/guild/screens/guild_screen.dart';
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
  Widget? extraPage;
  String? extraTitle;

  final pages = const [
    ComicListScreen(),
    ShopScreen(),
    GuildScreen(),
    ChatRoomListScreen(),
    ProfileScreen(),
  ];

  final titles = const [
    'Truyện',
    'Shop',
    'Bang phái',
    'Chat',
    'Tôi',
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  void _changeMainPage(int index) {
    setState(() {
      currentIndex = index;
      extraPage = null;
      extraTitle = null;
    });

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _openExtraPage({
    required Widget page,
    required String title,
  }) {
    setState(() {
      extraPage = page;
      extraTitle = title;
    });

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
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
    final body = extraPage ??
        IndexedStack(
          index: currentIndex,
          children: pages,
        );

    final title = extraTitle ?? titles[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
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
                              color: const Color(0xFF070B14),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
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
      drawer: _AppDrawer(
        currentIndex: currentIndex,
        isExtraPageOpen: extraPage != null,
        onChangeMainPage: _changeMainPage,
        onOpenRanking: () {
          _openExtraPage(
            page: const RankingScreen(),
            title: 'Bảng xếp hạng',
          );
        },
        onOpenAfk: () {
          _openExtraPage(
            page: const AfkScreen(),
            title: 'AFK',
          );
        },
        onOpenCultivation: () {
          _openExtraPage(
            page: const CultivationScreen(),
            title: 'Cảnh giới',
          );
        },
        onOpenMissions: () {
          _openExtraPage(
            page: const MissionScreen(),
            title: 'Nhiệm vụ',
          );
        },
      ),
      body: body,
      bottomNavigationBar: extraPage == null
          ? _BottomNavBar(
        currentIndex: currentIndex,
        onTap: _changeMainPage,
      )
          : null,
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B1020),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2A44)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFF0B1020),
            indicatorColor: const Color(0xFF6574FF).withOpacity(0.2),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (states) {
                final selected = states.contains(WidgetState.selected);

                return TextStyle(
                  color: selected
                      ? const Color(0xFFBFD0FF)
                      : Colors.white.withOpacity(0.54),
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                );
              },
            ),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                  (states) {
                final selected = states.contains(WidgetState.selected);

                return IconThemeData(
                  color: selected
                      ? const Color(0xFFBFD0FF)
                      : Colors.white.withOpacity(0.52),
                  size: 23,
                );
              },
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            height: 66,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Truyện',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded),
                label: 'Bang',
              ),
              NavigationDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum_rounded),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Tôi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.currentIndex,
    required this.isExtraPageOpen,
    required this.onChangeMainPage,
    required this.onOpenRanking,
    required this.onOpenAfk,
    required this.onOpenCultivation,
    required this.onOpenMissions,
  });

  final int currentIndex;
  final bool isExtraPageOpen;
  final ValueChanged<int> onChangeMainPage;
  final VoidCallback onOpenRanking;
  final VoidCallback onOpenAfk;
  final VoidCallback onOpenCultivation;
  final VoidCallback onOpenMissions;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF151B2D),
      child: SafeArea(
        child: Column(
          children: [
            _drawerHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(
                    selected: !isExtraPageOpen && currentIndex == 0,
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book_rounded,
                    title: 'Truyện',
                    subtitle: 'Khám phá truyện mới',
                    onTap: () => onChangeMainPage(0),
                  ),
                  _drawerItem(
                    selected: !isExtraPageOpen && currentIndex == 1,
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront_rounded,
                    title: 'Shop',
                    subtitle: 'Vật phẩm và tài nguyên',
                    onTap: () => onChangeMainPage(1),
                  ),
                  _drawerItem(
                    selected: !isExtraPageOpen && currentIndex == 2,
                    icon: Icons.groups_outlined,
                    selectedIcon: Icons.groups_rounded,
                    title: 'Bang phái',
                    subtitle: 'Gia nhập cộng đồng',
                    onTap: () => onChangeMainPage(2),
                  ),
                  _drawerItem(
                    selected: !isExtraPageOpen && currentIndex == 3,
                    icon: Icons.forum_outlined,
                    selectedIcon: Icons.forum_rounded,
                    title: 'Chat cộng đồng',
                    subtitle: 'Trò chuyện với đạo hữu',
                    highlight: true,
                    onTap: () => onChangeMainPage(3),
                  ),
                  _drawerItem(
                    selected: !isExtraPageOpen && currentIndex == 4,
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person_rounded,
                    title: 'Tài khoản',
                    subtitle: 'Hồ sơ và tài nguyên',
                    onTap: () => onChangeMainPage(4),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 6),
                    child: Text(
                      'Tính năng phụ',
                      style: TextStyle(
                        color: Color(0xFF8FA1C7),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  _drawerItem(
                    selected: false,
                    icon: Icons.auto_awesome_outlined,
                    selectedIcon: Icons.auto_awesome_rounded,
                    title: 'Cảnh giới',
                    subtitle: 'Tu luyện, đột phá và AFK hệ số',
                    highlight: true,
                    onTap: onOpenCultivation,
                  ),
                  _drawerItem(
                    selected: false,
                    icon: Icons.assignment_turned_in_outlined,
                    selectedIcon: Icons.assignment_turned_in_rounded,
                    title: 'Nhiệm vụ',
                    subtitle: 'Nhận vàng, EXP và vật phẩm',
                    highlight: true,
                    onTap: onOpenMissions,
                  ),
                  _drawerItem(
                    selected: false,
                    icon: Icons.emoji_events_outlined,
                    selectedIcon: Icons.emoji_events_rounded,
                    title: 'Bảng xếp hạng',
                    subtitle: 'Top cao thủ tu tiên',
                    onTap: onOpenRanking,
                  ),
                  _drawerItem(
                    selected: false,
                    icon: Icons.bolt_outlined,
                    selectedIcon: Icons.bolt_rounded,
                    title: 'AFK',
                    subtitle: 'Nhận thưởng tu luyện',
                    onTap: onOpenAfk,
                  ),
                ],
              ),
            ),
            _drawerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _drawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF10182B),
            Color(0xFF172345),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF253251)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF6574FF).withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF6574FF)),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Color(0xFF8FB0FF),
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Comic Cultivation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Đọc truyện • bang phái • chat cộng đồng',
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required bool selected,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2848A9).withOpacity(0.42)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6574FF).withOpacity(0.7)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6574FF).withOpacity(0.2)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? const Color(0xFFBFD0FF)
                      : Colors.white.withOpacity(0.68),
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight:
                              selected ? FontWeight.w900 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (highlight) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB020).withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                const Color(0xFFFFB020).withOpacity(0.45),
                              ),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Color(0xFFFFD27A),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.42),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBFD0FF),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerFooter() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222E4C)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            color: Color(0xFFFFD27A),
            size: 20,
          ),
          const SizedBox(width: 9),
        ],
      ),
    );
  }
}