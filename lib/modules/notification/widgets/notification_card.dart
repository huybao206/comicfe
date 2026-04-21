import 'package:flutter/material.dart';

import '../model/notification_item.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMarkRead,
  });

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('notification_${item.id}'),
      direction: item.isRead ? DismissDirection.none : DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onMarkRead();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C5E3F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.done_all_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Đánh dấu đã đọc',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: item.isRead
                ? const LinearGradient(
              colors: [
                Color(0xFF18130E),
                Color(0xFF130F0B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : const LinearGradient(
              colors: [
                Color(0xFF2A2014),
                Color(0xFF18120C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isRead
                  ? const Color(0xFF5C4723)
                  : const Color(0xFFC89A3A),
              width: item.isRead ? 1 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingIcon(typeCode: item.typeCode, isRead: item.isRead),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: item.isRead
                                  ? const Color(0xFFE0D0AF)
                                  : const Color(0xFFFFE7AE),
                              fontSize: 15.5,
                              fontWeight:
                              item.isRead ? FontWeight.w700 : FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!item.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE64545),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.content,
                      style: TextStyle(
                        color: item.isRead
                            ? const Color(0xFFC8B894)
                            : const Color(0xFFE6D7B5),
                        height: 1.5,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _TypeChip(typeCode: item.typeCode),
                        const Spacer(),
                        Text(
                          _formatTime(item.createdAt),
                          style: const TextStyle(
                            color: Color(0xFFB89E70),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';

    return '${time.day}/${time.month}/${time.year}';
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.typeCode,
    required this.isRead,
  });

  final String typeCode;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final icon = _iconByType(typeCode);
    final color = isRead ? const Color(0xFFCCAE76) : const Color(0xFFFFD37A);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF2A1D11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead ? const Color(0xFF6C5227) : const Color(0xFFC89A3A),
        ),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  IconData _iconByType(String typeCode) {
    switch (typeCode.toUpperCase()) {
      case 'SYSTEM':
        return Icons.settings_suggest_rounded;
      case 'GUILD':
        return Icons.groups_rounded;
      case 'SHOP':
        return Icons.storefront_rounded;
      case 'VIP':
        return Icons.workspace_premium_rounded;
      case 'MISSION':
        return Icons.flag_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.typeCode,
  });

  final String typeCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF6D5123)),
      ),
      child: Text(
        typeCode.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFF1D494),
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}