import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final descController = TextEditingController();

  bool isSubmitting = false;
  String? errorText;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  String _makeSlug(String input) {
    var value = input.trim().toLowerCase();
    const from = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const to = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

    for (var i = 0; i < from.length; i++) {
      value = value.replaceAll(from[i], to[i]);
    }

    value = value
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    return value.isEmpty ? 'bang-hoi-${DateTime.now().millisecondsSinceEpoch}' : value;
  }

  Future<void> submit() async {
    if (isSubmitting) return;

    final name = nameController.text.trim();
    final description = descController.text.trim();

    if (name.isEmpty) {
      setState(() {
        errorText = 'Tên bang hội là bắt buộc';
      });
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      isSubmitting = true;
      errorText = null;
    });

    try {
      final ok = await widget.guildProvider.createGuild(
        name: name,
        slug: _makeSlug(name),
        description: description.isEmpty ? null : description,
      );

      if (!mounted) return;

      if (ok) {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        isSubmitting = false;
        errorText = widget.guildProvider.errorMessage ?? 'Tạo bang hội thất bại';
      });
      HapticFeedback.heavyImpact();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
        errorText = error.toString().replaceFirst('Exception: ', '');
      });
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF15110C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: errorText == null ? const Color(0xFF8B6A2B) : const Color(0xFFFF6B6B),
          width: 1.2,
        ),
      ),
      title: const Text(
        'Tạo bang hội',
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
              label: 'Tên bang hội',
            ),
            const SizedBox(height: 12),
            _GuildInput(
              controller: descController,
              label: 'Mô tả',
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Text(
              'Slug sẽ được tạo tự động. Nếu đủ cấp và đủ vàng, sau khi tạo bạn sẽ vào thẳng hồ sơ bang hội.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.52),
                fontSize: 12.2,
                height: 1.35,
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A1414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.55)),
                ),
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    color: Color(0xFFFFD1D1),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
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
