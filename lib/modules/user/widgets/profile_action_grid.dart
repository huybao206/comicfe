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
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF17110C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF735624)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF23180F),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF5E451D)),
                  ),
                  child: Icon(
                    item.icon,
                    color: const Color(0xFFE0B85C),
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFFF6E7BE),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: Color(0xFFCCB991),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}