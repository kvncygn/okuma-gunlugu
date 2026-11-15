import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'book_cover.dart';

/// Mockup'taki `#story` (9:16) kartı (`drawStory()`).
/// RepaintBoundary ile sarılarak yüksek çözünürlüklü PNG çıktısı üretmek için kullanılır.
class StoryCard extends StatelessWidget {
  final String quoteText;
  final String bookKey;
  final String bookTitle;
  final String bookAuthor;
  final String? coverUrl;
  final int page;
  final int themeIndex;
  final double width;
  final double height;

  const StoryCard({
    super.key,
    required this.quoteText,
    required this.bookKey,
    required this.bookTitle,
    required this.bookAuthor,
    this.coverUrl,
    required this.page,
    this.themeIndex = 0,
    this.width = 184,
    this.height = 327,
  });

  @override
  Widget build(BuildContext context) {
    final safeIdx = themeIndex.clamp(0, AppColors.storyThemes.length - 1);
    final colors = AppColors.storyThemes[safeIdx];

    // 165deg CSS linear-gradient dönüşümü
    const angleRad = (165 - 90) * (math.pi / 180.0);
    final begin = Alignment(-math.cos(angleRad), -math.sin(angleRad));
    final end = Alignment(math.cos(angleRad), math.sin(angleRad));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Sağ üst dekoratif daire: `absolute -right-10 -top-10 w-36 h-36 rounded-full bg-white/10`
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“',
                  style: AppTypography.serif(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.5),
                    height: 0.9,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      quoteText,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.serif(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.30),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      BookCover(
                        bookKey: bookKey,
                        title: bookTitle,
                        coverUrl: coverUrl,
                        width: 34,
                        height: 50,
                        borderRadius: 6,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$bookAuthor · s. ${page > 0 ? page : '-'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'OKUMA GÜNLÜĞÜM',
                    style: AppTypography.sans(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Colors.white.withOpacity(0.50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
