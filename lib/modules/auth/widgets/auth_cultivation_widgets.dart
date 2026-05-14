import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CultivationAuthBackground extends StatelessWidget {
  const CultivationAuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.25,
              colors: [
                Color(0xFF1A1732),
                Color(0xFF0B0B12),
                Color(0xFF050505),
              ],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -70,
          child: _GlowOrb(
            size: 230,
            color: const Color(0xFFD4A02F).withOpacity(0.18),
          ),
        ),
        Positioned(
          bottom: 80,
          left: -100,
          child: _GlowOrb(
            size: 240,
            color: const Color(0xFF6574FF).withOpacity(0.12),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _FantasyBackgroundPainter(),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

class _FantasyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = const Color(0xFFE8C36D).withOpacity(0.18)
      ..strokeWidth = 1.2;

    final stars = [
      Offset(size.width * .12, size.height * .13),
      Offset(size.width * .80, size.height * .16),
      Offset(size.width * .24, size.height * .32),
      Offset(size.width * .90, size.height * .39),
      Offset(size.width * .12, size.height * .68),
      Offset(size.width * .72, size.height * .78),
      Offset(size.width * .44, size.height * .20),
      Offset(size.width * .58, size.height * .88),
    ];

    for (final p in stars) {
      canvas.drawCircle(p, 1.2, starPaint);
    }

    final mountainPaint = Paint()
      ..color = const Color(0xFF090A10).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .78)
      ..lineTo(size.width * .18, size.height * .67)
      ..lineTo(size.width * .34, size.height * .82)
      ..lineTo(size.width * .52, size.height * .64)
      ..lineTo(size.width * .73, size.height * .80)
      ..lineTo(size.width, size.height * .63)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, mountainPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFFD4A02F).withOpacity(0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * .5, size.height * .28),
        78 + i * 18,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CultivationLogo extends StatelessWidget {
  const CultivationLogo({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 96.0 : 132.0;
    final bookSize = compact ? 44.0 : 60.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _LogoRingPainter(),
          ),
          Positioned(
            top: compact ? 8 : 12,
            child: Container(
              width: 7,
              height: compact ? 75 : 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFE9A8),
                    Color(0xFFD4A02F),
                    Color(0xFF6F4A12),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8C36D).withOpacity(.42),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: compact ? 1 : 4,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9A8),
                  border: Border.all(color: const Color(0xFF8A611C)),
                ),
              ),
            ),
          ),
          Icon(
            Icons.menu_book_rounded,
            size: bookSize,
            color: const Color(0xFFFFE08A),
          ),
        ],
      ),
    );
  }
}

class _LogoRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final glowPaint = Paint()
      ..color = const Color(0xFFE8C36D).withOpacity(.10)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width * .43, glowPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFFE8C36D).withOpacity(.76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawCircle(center, size.width * .39, ringPaint);

    ringPaint.color = const Color(0xFFE8C36D).withOpacity(.22);
    canvas.drawCircle(center, size.width * .47, ringPaint);

    final tickPaint = Paint()
      ..color = const Color(0xFFE8C36D).withOpacity(.75)
      ..strokeWidth = 1.2;

    for (var i = 0; i < 16; i++) {
      final a = (math.pi * 2 / 16) * i;
      final r1 = size.width * .41;
      final r2 = size.width * .46;

      final p1 = Offset(
        center.dx + math.cos(a) * r1,
        center.dy + math.sin(a) * r1,
      );

      final p2 = Offset(
        center.dx + math.cos(a) * r2,
        center.dy + math.sin(a) * r2,
      );

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthOrnamentTitle extends StatelessWidget {
  const AuthOrnamentTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: _GoldLine()),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFF8E6B5),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: _GoldLine()),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFF8E6B5).withOpacity(.66),
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _GoldLine extends StatelessWidget {
  const _GoldLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A02F).withOpacity(0),
            const Color(0xFFD4A02F).withOpacity(.75),
            const Color(0xFFD4A02F).withOpacity(0),
          ],
        ),
      ),
    );
  }
}
class AuthGlassPanel extends StatelessWidget {
  const AuthGlassPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // Giữ padding để form vẫn thoáng, nhưng bỏ nền đen bao ngoài.
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),

      // Không còn nền riêng, không viền, không bóng.
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),

      child: child,
    );
  }
}
// class AuthGlassPanel extends StatelessWidget {
//   const AuthGlassPanel({
//     super.key,
//     required this.child,
//   });
//
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
//       decoration: BoxDecoration(
//         color: const Color(0xE6110F0C),
//         borderRadius: BorderRadius.circular(26),
//
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.45),
//             blurRadius: 24,
//             offset: const Offset(0, 16),
//           ),
//           BoxShadow(
//             color: const Color(0xFFD4A02F).withOpacity(.06),
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// class _PanelBorderPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final r = RRect.fromRectAndRadius(
//       Offset.zero & size,
//       const Radius.circular(26),
//     );
//
//     final paint = Paint()
//       ..color = const Color(0xFFD4A02F).withOpacity(.72)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.1;
//
//     canvas.drawRRect(r, paint);
//
//     final cornerPaint = Paint()
//       ..color = const Color(0xFFFFE08A).withOpacity(.65)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.2;
//
//     const d = 22.0;
//
//     canvas.drawLine(const Offset(18, 0), const Offset(d + 26, 0), cornerPaint);
//     canvas.drawLine(const Offset(0, 18), const Offset(0, d + 26), cornerPaint);
//
//     canvas.drawLine(
//       Offset(size.width - 18, 0),
//       Offset(size.width - d - 26, 0),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       Offset(size.width, 18),
//       Offset(size.width, d + 26),
//       cornerPaint,
//     );
//
//     canvas.drawLine(
//       Offset(18, size.height),
//       Offset(d + 26, size.height),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       Offset(0, size.height - 18),
//       Offset(0, size.height - d - 26),
//       cornerPaint,
//     );
//
//     canvas.drawLine(
//       Offset(size.width - 18, size.height),
//       Offset(size.width - d - 26, size.height),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       Offset(size.width, size.height - 18),
//       Offset(size.width, size.height - d - 26),
//       cornerPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class CultivationTextField extends StatelessWidget {
  const CultivationTextField({
    super.key,
    required this.controller,
    required this.validator,
    required this.icon,
    required this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.keyboardType,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.onChanged,
    this.helperText,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;
  final IconData icon;
  final String label;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      cursorColor: const Color(0xFFE0B85C),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFD8C08A)),
        helperText: helperText,
        helperStyle: TextStyle(
          color: const Color(0xFFE8C36D).withOpacity(.58),
          fontSize: 11.5,
        ),
        filled: true,
        fillColor: const Color(0xFF0C0B09).withOpacity(.76),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFE0B85C),
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFD4A02F).withOpacity(.34),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE0B85C),
            width: 1.35,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE64545)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE64545)),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFFF9E9E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GoldAuthButton extends StatelessWidget {
  const GoldAuthButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFE08A),
              Color(0xFFD4A02F),
              Color(0xFFB97D1D),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A02F).withOpacity(.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.grey.shade700,
            shadowColor: Colors.transparent,
            foregroundColor: const Color(0xFF211407),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF211407),
            ),
          )
              : Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSwitchLine extends StatelessWidget {
  const AuthSwitchLine({
    super.key,
    required this.normalText,
    required this.actionText,
    required this.onTap,
  });

  final String normalText;
  final String actionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$normalText ',
              style: TextStyle(
                color: const Color(0xFFF8E6B5).withOpacity(.62),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: actionText,
              style: const TextStyle(
                color: Color(0xFFE8C36D),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}