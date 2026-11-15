import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/reading_calculator.dart';

/// Mockup'taki `cv(k, w, h)` fonksiyonunun birebir Flutter karşılığı.
/// `coverUrl` varsa Google Books kapağını gösterir; yoksa veya yüklenemezse
/// `PAL[ci(k)]` 150° gradyan kapağını ve iç sırt parlaklığını (`inset 3px 0 0 rgba(255,255,255,.18)`) çizer.
class BookCover extends StatelessWidget {
  final String bookKey;
  final String title;
  final String? coverUrl;
  final double width;
  final double height;
  final double borderRadius;

  const BookCover({
    super.key,
    required this.bookKey,
    required this.title,
    this.coverUrl,
    this.width = 96,
    this.height = 140,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final paletteIndex = ReadingCalculator.coverPaletteIndex(
      bookKey.isNotEmpty ? bookKey : title,
    );
    final colors = AppColors.coverPalettes[paletteIndex];

    // 150deg CSS linear-gradient dönüşümü
    const angleRad = (150 - 90) * (math.pi / 180.0);
    final begin = Alignment(-math.cos(angleRad), -math.sin(angleRad));
    final end = Alignment(math.cos(angleRad), math.sin(angleRad));

    final displayTitle = (width > 90 && title.toLowerCase() == 'dune')
        ? 'DUNE'
        : title;
    final fontSize = width > 90 ? 15.0 : (width < 50 ? 7.5 : 10.5);

    Widget buildGradientFallback() {
      return Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(width < 50 ? 4 : 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: colors,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: width < 50 ? 10 : 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              displayTitle,
              maxLines: width < 50 ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.serif(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.15,
              ),
            ),
          ],
        ),
      );
    }

    final hasValidCoverUrl = coverUrl != null && coverUrl!.trim().isNotEmpty;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.35),
            offset: const Offset(0, 6),
            blurRadius: 14,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasValidCoverUrl)
              Image.network(
                coverUrl!.replaceFirst('http://', 'https://'),
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => buildGradientFallback(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return buildGradientFallback();
                },
              )
            else
              buildGradientFallback(),

            // Sol sırt parlaklığı: `inset 3px 0 0 rgba(255,255,255,.18)`
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3,
              child: ColoredBox(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
