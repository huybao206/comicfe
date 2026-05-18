import 'package:flutter/material.dart';

class ProfileActionGrid extends StatelessWidget {
  const ProfileActionGrid({
    super.key,
    required this.items,
  });

  final List<ProfileActionItemData> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.96,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF10182B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: item.color.withOpacity(0.36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -22,
                    top: -22,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: item.color.withOpacity(0.36),
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFFFFE9B0),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.50),
                          fontSize: 12,
                          height: 1.32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileActionItemData {
  const ProfileActionItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
}