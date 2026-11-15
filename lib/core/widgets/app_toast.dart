import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Mockup'taki `#toast` bileşeni:
/// `bottom-28 px-4 py-2.5 rounded-full bg-ink text-cream text-sm`
class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  static void show(BuildContext context, String message) {
    _timer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (ctx) => _ToastPill(message: message),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _timer = Timer(const Duration(milliseconds: 2200), () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}

class _ToastPill extends StatefulWidget {
  final String message;

  const _ToastPill({required this.message});

  @override
  State<_ToastPill> createState() => _ToastPillState();
}

class _ToastPillState extends State<_ToastPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 108,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _controller,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    fontSize: 14,
                    color: AppColors.cream,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
