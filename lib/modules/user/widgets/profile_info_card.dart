import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.email,
    required this.username,
  });

  final String email;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đạo hữu',
            style: TextStyle(
              color: Color(0xFFF6E7BE),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.person_outline_rounded,
            label: 'Tài khoản',
            value: username.isNotEmpty ? username : 'Chưa cập nhật',
          ),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email.isNotEmpty ? email : 'Chưa cập nhật',
          ),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.auto_awesome_rounded,
            label: 'Danh hiệu',
            value: 'Hành giả sơ kỳ',
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF23180F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5E451D)),
          ),
          child: Icon(icon, color: const Color(0xFFE0B85C), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFB89E70),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFE8D7B3),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}