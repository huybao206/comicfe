import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import 'edit_profile_field.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController name;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;

    name = TextEditingController(
      text: profile?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();

    final ok = await provider.updateProfile(
      displayName: name.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Cập nhật thành công'
              : (provider.errorMessage ?? 'Backend chưa hỗ trợ cập nhật hồ sơ'),
        ),
      ),
    );

    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<UserProvider>().isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            EditProfileField(
              label: 'Tên hiển thị',
              controller: name,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) {
                  return 'Không được để trống';
                }
                if ((v ?? '').trim().length < 2) {
                  return 'Tên quá ngắn';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF23180F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF5E451D)),
              ),
              child: const Text(
                'Backend hiện chưa có API cập nhật hồ sơ cho app user. Màn hình này đang khớp dữ liệu thật từ hệ thống và sẵn sàng để nối API sau.',
                style: TextStyle(
                  color: Color(0xFFE2D1AE),
                  height: 1.5,
                  fontSize: 12.8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC7962F),
                  foregroundColor: const Color(0xFF24170B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  loading ? 'Đang lưu...' : 'Lưu thay đổi',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}