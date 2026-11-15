import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Async veriler için mockup tasarım diline uygun Loading / Error / Empty bileşenleri.
class AsyncStateView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final String emptyTitle;
  final String? emptySubtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final VoidCallback? onRetry;
  final Widget child;

  const AsyncStateView({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.isEmpty = false,
    this.emptyTitle = 'Henüz kayıt bulunmuyor.',
    this.emptySubtitle,
    this.actionLabel,
    this.onActionTap,
    this.onRetry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(
            color: AppColors.terra,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.sand),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              color: AppColors.terra,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 13,
                color: AppColors.ink.withOpacity(0.75),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 15),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ],
        ),
      );
    }

    if (isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.sand),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.bookOpen,
              color: AppColors.ink.withOpacity(0.35),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.serif(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (emptySubtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                emptySubtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  fontSize: 13,
                  color: AppColors.ink.withOpacity(0.6),
                ),
              ),
            ],
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terra,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return child;
  }
}
