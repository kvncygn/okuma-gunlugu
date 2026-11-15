import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mockup'taki `.sheet` bileşeni:
/// `bg-cream rounded-t-[32px] p-6 pb-10` ve üstte `w-10 h-1 bg-ink/20 rounded-full` tutamaç.
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 32),
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    Color barrierColor = const Color(0x801E293B),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: builder(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: padding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.ink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
