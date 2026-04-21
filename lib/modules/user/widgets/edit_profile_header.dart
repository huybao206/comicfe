import 'package:flutter/material.dart';

class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
  });

  final String displayName;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B1E12),
            Color(0xFF17110C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7A5A26)),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC7962F), width: 2),
              color: const Color(0xFF21170F),
            ),
            child: ClipOval(
              child: hasAvatar
                  ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(),
              )
                  : _avatarFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Color(0xFFF8E6B5),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email.isNotEmpty ? email : 'Chưa cập nhật email',
                  style: const TextStyle(
                    color: Color(0xFFD7C39A),
                    fontSize: 12.8,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23180F),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF6D5123)),
                  ),
                  child: const Text(
                    'Thông tin tài khoản hiện tại',
                    style: TextStyle(
                      color: Color(0xFFF1D494),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        size: 38,
        color: Color(0xFFE0B85C),
      ),
    );
  }
}