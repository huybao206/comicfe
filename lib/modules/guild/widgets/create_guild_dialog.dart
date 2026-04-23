import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/guild_provider.dart';

Future<bool?> showCreateGuildDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final slugController = TextEditingController();
  final descController = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      bool isSubmitting = false;

      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> submit() async {
            if (isSubmitting) return;

            setState(() {
              isSubmitting = true;
            });

            final success = await context.read<GuildProvider>().createGuild(
              name: nameController.text.trim(),
              slug: slugController.text.trim(),
              description: descController.text.trim(),
            );

            if (!dialogContext.mounted) return;

            Navigator.of(dialogContext).pop(success);
          }

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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                isSubmitting ? null : () => Navigator.of(dialogContext).pop(false),
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
        },
      );
    },
  );

  nameController.dispose();
  slugController.dispose();
  descController.dispose();

  return result;
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