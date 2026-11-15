import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Mockup'taki `<article class="rounded-3xl bg-white border border-sand p-5 ...">`
/// alıntı kartı + düzenleme/silme aksiyonları.
class QuoteCard extends StatelessWidget {
  final String text;
  final String note;
  final int page;
  final String bookTitle;
  final String bookAuthor;
  final VoidCallback onShareTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const QuoteCard({
    super.key,
    required this.text,
    required this.note,
    required this.page,
    required this.bookTitle,
    required this.bookAuthor,
    required this.onShareTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sand),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                LucideIcons.quote,
                size: 28,
                color: AppColors.terra.withOpacity(0.4),
              ),
              if (onEditTap != null || onDeleteTap != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEditTap != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Düzenle',
                        onPressed: onEditTap,
                        icon: Icon(
                          LucideIcons.pencil,
                          size: 16,
                          color: AppColors.ink.withOpacity(0.45),
                        ),
                      ),
                    if (onDeleteTap != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Sil',
                        onPressed: onDeleteTap,
                        icon: Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: AppColors.terra.withOpacity(0.75),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: AppTypography.quoteBody,
          ),
          if (note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.sage.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.sans(
                    fontSize: 13,
                    color: AppColors.ink.withOpacity(0.8),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: 'Notum: ',
                      style: AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sage,
                      ),
                    ),
                    TextSpan(text: note),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.terra.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  's. ${page > 0 ? page : '-'}',
                  style: AppTypography.sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.terra,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$bookTitle · $bookAuthor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sans(
                    fontSize: 12,
                    color: AppColors.ink.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onShareTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.cream,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(LucideIcons.share2, size: 16),
              label: Text(
                'Story Kartı Olarak Paylaş',
                style: AppTypography.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
