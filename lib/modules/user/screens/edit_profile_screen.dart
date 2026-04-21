import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../widgets/edit_profile_form.dart';
import '../widgets/edit_profile_header.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A07),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: Color(0xFFF8E6B5),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EditProfileHeader(
            displayName: profile?.displayName ?? profile?.username ?? 'Đạo hữu',
            email: profile?.email ?? '',
            avatarUrl: profile?.avatarUrl,
          ),
          const SizedBox(height: 16),
          const EditProfileForm(),
        ],
      ),
    );
  }
}