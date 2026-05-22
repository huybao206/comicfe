import 'dart:async';

import 'package:flutter/material.dart';

class AppTopToast {
  static OverlayEntry? _activeEntry;

  static void show(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 5),
        IconData icon = Icons.notifications_active_rounded,
        Color startColor = const Color(0xFF16A34A),
        Color endColor = const Color(0xFF64748B),
      }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _removeActive();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppTopToastEntry(
        message: message.trim().isEmpty ? 'Thông báo' : message.trim(),
        icon: icon,
        duration: duration,
        startColor: startColor,
        endColor: endColor,
        onDismissed: () {
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
          try {
            entry.remove();
          } catch (_) {}
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void fromSnackBar(BuildContext context, SnackBar snackBar) {
    final message = _messageFromWidget(snackBar.content);
    final icon = _iconFromSnackBar(snackBar);

    show(
      context,
      message,
      icon: icon,
      duration: const Duration(seconds: 5),
      startColor: const Color(0xFF16A34A),
      endColor: const Color(0xFF64748B),
    );
  }

  static void _removeActive() {
    final entry = _activeEntry;
    _activeEntry = null;
    if (entry == null) return;
    try {
      entry.remove();
    } catch (_) {}
  }

  static String _messageFromWidget(Widget content) {
    if (content is Text) {
      return content.data ?? content.textSpan?.toPlainText() ?? 'Thông báo';
    }
    return 'Thông báo';
  }

  static IconData _iconFromSnackBar(SnackBar snackBar) {
    final bg = snackBar.backgroundColor;
    if (bg != null && bg.red > bg.green + 25) {
      return Icons.error_outline_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }
}

class _AppTopToastEntry extends StatefulWidget {
  const _AppTopToastEntry({
    required this.message,
    required this.icon,
    required this.duration,
    required this.startColor,
    required this.endColor,
    required this.onDismissed,
  });

  final String message;
  final IconData icon;
  final Duration duration;
  final Color startColor;
  final Color endColor;
  final VoidCallback onDismissed;

  @override
  State<_AppTopToastEntry> createState() => _AppTopToastEntryState();
}

class _AppTopToastEntryState extends State<_AppTopToastEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _backgroundColor;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _backgroundColor = ColorTween(
      begin: widget.startColor,
      end: widget.endColor,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 72,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 28,
      ),
    ]).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0.18, -0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _timer = Timer(widget.duration, widget.onDismissed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth < 390 ? screenWidth - 24 : 360.0;

    return Positioned(
      top: 12,
      right: 12,
      child: SafeArea(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return FractionalTranslation(
                translation: _slide.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth < 240 ? 240 : maxWidth,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _backgroundColor.value ?? widget.startColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(widget.icon, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  widget.message,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}
