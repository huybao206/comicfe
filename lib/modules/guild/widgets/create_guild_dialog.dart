import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/guild_provider.dart';

Future<bool?> showCreateGuildDialog(BuildContext context) {
  final guildProvider = context.read<GuildProvider>();

  return showDialog<bool>(
    context: context,
    builder: (_) => _CreateGuildDialog(
      guildProvider: guildProvider,
    ),
  );
}

class _CreateGuildDialog extends StatefulWidget {
  const _CreateGuildDialog({
    required this.guildProvider,
  });

  final GuildProvider guildProvider;

  @override
  State<_CreateGuildDialog> createState() => _CreateGuildDialogState();
}

class _CreateGuildDialogState extends State<_CreateGuildDialog> {
  final nameController = TextEditingController();
  final slugController = TextEditingController();
  final descController = TextEditingController();

  bool isSubmitting = false;
  String? errorText;

  @override
  void dispose() {
    nameController.dispose();
    slugController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (isSubmitting) return;

    final name = nameController.text.trim();
    final slug = slugController.text.trim();
    final description = descController.text.trim();

    if (name.isEmpty || slug.isEmpty) {
      setState(() {
        errorText = 'Tên guild và slug là bắt buộc';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorText = null;
    });

    try {
      await widget.guildProvider.guildService.createGuild(
        name: name,
        slug: slug,
        description: description,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
        errorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF15110C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF8B6A2B), width: 1.2),
      ),
      title: const Text(
        'Tạo Guild',
        style: TextStyle(
          color: Color(0xFFF6E7BE),
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GuildInput(
              controller: nameController,
              label: 'Tên guild',
            ),
            const SizedBox(height: 12),
            _GuildInput(
              controller: slugController,
              label: 'Slug',
            ),
            const SizedBox(height: 12),
            _GuildInput(
              controller: descController,
              label: 'Mô tả',
              maxLines: 3,
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                errorText!,
                style: const TextStyle(
                  color: Color(0xFFFFB4A9),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        FilledButton(
          onPressed: isSubmitting ? null : submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC7962F),
            foregroundColor: const Color(0xFF24170B),
          ),
          child: isSubmitting
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF24170B),
            ),
          )
              : const Text(
            'Tạo',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _GuildInput extends StatelessWidget {
  const _GuildInput({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFD8C08A)),
        filled: true,
        fillColor: const Color(0xFF21170F),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6E5423)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0B85C)),
        ),
      ),
    );
  }
}