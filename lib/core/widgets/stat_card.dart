import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Ana sayfadaki 3'lü istatistik kartı:
/// `<div class="rounded-2xl bg-white border border-sand p-3">`
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              fontSize: 10.5,
              color: AppColors.ink.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.serif(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              fontSize: 11,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
