import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_top_toast.dart';
import '../provider/user_provider.dart';
import 'edit_profile_field.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late TextEditingController name;
  late TextEditingController bio;
  File? selectedAvatar;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;

    name = TextEditingController(text: profile?.displayName ?? '');
    bio = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    bio.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 86,
        maxWidth: 1000,
      );

      if (!mounted) return;
      if (pickedFile == null) return;

      setState(() {
        selectedAvatar = File(pickedFile.path);
      });

      AppTopToast.show(
        context,
        'Đã chọn ảnh đại diện mới. Bấm lưu để cập nhật.',
        icon: Icons.image_rounded,
      );
    } catch (error) {
      if (!mounted) return;
      AppTopToast.show(
        context,
        'Không chọn được ảnh: ${error.toString().replaceFirst('Exception: ', '')}',
        icon: Icons.error_outline_rounded,
        startColor: const Color(0xFFDC2626),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();

    final ok = await provider.updateProfile(
      displayName: name.text.trim(),
      bio: bio.text.trim(),
      avatarFile: selectedAvatar,
    );

    if (!mounted) return;

    AppTopToast.show(
      context,
      ok ? 'Cập nhật hồ sơ thành công' : (provider.errorMessage ?? 'Không cập nhật được hồ sơ'),
      icon: ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
      startColor: ok ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
    );

    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = provider.profile;
    final loading = provider.isUpdating;
    final currentAvatar = profile?.avatarUrl;
    final hasCurrentAvatar = currentAvatar != null && currentAvatar.trim().isNotEmpty;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC7962F), width: 1.5),
                    color: const Color(0xFF23180F),
                  ),
                  child: ClipOval(
                    child: selectedAvatar != null
                        ? Image.file(selectedAvatar!, fit: BoxFit.cover)
                        : hasCurrentAvatar
                        ? Image.network(
                      currentAvatar,
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
                      const Text(
                        'Ảnh đại diện',
                        style: TextStyle(
                          color: Color(0xFFF8E6B5),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chọn ảnh trực tiếp từ máy, hệ thống sẽ upload lên server.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.52),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: loading ? null : _pickAvatar,
                        icon: const Icon(Icons.photo_library_rounded, size: 17),
                        label: const Text('Chọn ảnh'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFFD27A),
                          side: const BorderSide(color: Color(0xFF735624)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            EditProfileField(
              label: 'Tên hiển thị',
              controller: name,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Không được để trống';
                if ((v ?? '').trim().length < 2) return 'Tên quá ngắn';
                return null;
              },
            ),
            const SizedBox(height: 16),
            EditProfileField(
              label: 'Giới thiệu ngắn',
              controller: bio,
              maxLines: 4,
              validator: (v) {
                if ((v ?? '').trim().length > 1000) return 'Giới thiệu không được vượt quá 1000 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : _save,
                icon: loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF24170B),
                  ),
                )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  loading ? 'Đang lưu...' : 'Lưu thay đổi',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC7962F),
                  foregroundColor: const Color(0xFF24170B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
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
