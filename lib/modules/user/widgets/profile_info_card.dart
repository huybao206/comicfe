import 'package:flutter/material.dart';

import '../model/user_profile.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(
            'Tài nguyên đạo hữu',
            Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _ResourceBox(
                  icon: Icons.monetization_on_outlined,
                  title: 'Vàng',
                  value: '${profile.gold}',
                  color: const Color(0xFFFFD27A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResourceBox(
                  icon: Icons.circle_outlined,
                  title: 'Coin',
                  value: '${profile.coin}',
                  color: const Color(0xFF8FB0FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResourceBox(
                  icon: Icons.diamond_outlined,
                  title: 'Linh thạch',
                  value: '${profile.spiritStone}',
                  color: const Color(0xFFB58CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _title(
            'Thông tin tài khoản',
            Icons.person_outline_rounded,
          ),
          const SizedBox(height: 13),
          _infoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Username',
            value: profile.username.isNotEmpty
                ? profile.username
                : 'Chưa cập nhật',
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value:
            profile.email.isNotEmpty ? profile.email : 'Chưa cập nhật',
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.groups_rounded,
            label: 'Bang phái',
            value: profile.hasGuild
                ? (profile.guildName ?? 'Đã gia nhập')
                : 'Chưa tham gia',
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'VIP',
            value: profile.vipDisplayName,
          ),
        ],
      ),
    );
  }

  Widget _title(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A02F).withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4A02F).withOpacity(0.42),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFFD27A),
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFE9B0),
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFFFFD27A),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFE9B0),
                fontWeight: FontWeight.w900,
                fontSize: 12.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceBox extends StatelessWidget {
  const _ResourceBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.46),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}