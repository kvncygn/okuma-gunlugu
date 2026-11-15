import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mockup'taki `.bar` sınıflı animasyonlu ilerleme çubuğu.
class ProgressBar extends StatelessWidget {
  /// 0 ile 100 arasında yüzde değeri.
  final int percentage;
  final double height;
  final Color trackColor;
  final bool useGradient;
  final Color solidColor;

  const ProgressBar({
    super.key,
    required this.percentage,
    this.height = 10.0,
    this.trackColor = AppColors.sand,
    this.useGradient = true,
    this.solidColor = AppColors.terra,
  });

  @override
  Widget build(BuildContext context) {
    final factor = (percentage.clamp(0, 100)) / 100.0;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final targetWidth = constraints.maxWidth * factor;
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 550),
              curve: const Cubic(0.2, 0.8, 0.2, 1.0),
              width: targetWidth,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: useGradient ? AppColors.terraGradient : null,
                color: useGradient ? null : solidColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
