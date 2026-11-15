import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/story_card.dart';
import '../../../home/domain/book.dart';
import '../../domain/quote.dart';

/// Mockup'taki `#shareModal` (Story Önizleme · 9:16) bileşeni.
/// `RepaintBoundary` ile yüksek çözünürlüklü PNG üretir, `gal` ile galeriye kaydeder
/// ve `share_plus` ile paylaşır.
class StoryShareSheet extends StatefulWidget {
  final Quote quote;
  final Book? book;

  const StoryShareSheet({
    super.key,
    required this.quote,
    this.book,
  });

  static Future<void> show(
    BuildContext context, {
    required Quote quote,
    Book? book,
  }) {
    return AppBottomSheet.show(
      context: context,
      barrierColor: const Color(0xBF1E293B), // bg-ink/75
      builder: (_) => StoryShareSheet(quote: quote, book: book),
    );
  }

  @override
  State<StoryShareSheet> createState() => _StoryShareSheetState();
}

class _StoryShareSheetState extends State<StoryShareSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  int _themeIndex = 0;
  bool _isBusy = false;

  Future<Uint8List?> _capturePngBytes() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _saveToGallery() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final pngBytes = await _capturePngBytes();
      if (pngBytes == null) throw Exception('PNG üretilemedi');

      if (!kIsWeb) {
        final hasAccess = await Gal.hasAccess(toAlbum: true);
        if (!hasAccess) {
          await Gal.requestAccess(toAlbum: true);
        }

        await Gal.putImageBytes(
          pngBytes,
          name: 'okuma_gunlugu_story_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (!mounted) return;
      AppToast.show(context, 'Görsel galeriye kaydedildi 📥');
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Galeriye kaydedilemedi');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _shareStory() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final pngBytes = await _capturePngBytes();
      if (pngBytes == null) throw Exception('PNG üretilemedi');

      final fileName =
          'story_${widget.quote.id.isNotEmpty ? widget.quote.id : DateTime.now().millisecondsSinceEpoch}.png';

      final bookTitle = widget.book?.title ?? 'Okuma Günlüğüm';
      await Share.shareXFiles(
        [
          XFile.fromData(
            pngBytes,
            name: fileName,
            mimeType: 'image/png',
          ),
        ],
        text: '“${widget.quote.text}” — $bookTitle',
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(context, 'Story’de paylaşıldı ✨');
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Paylaşım başlatılamadı');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookTitle = widget.book?.title ?? 'Kitap';
    final bookAuthor = widget.book?.author ?? 'Yazar';

    return AppBottomSheet(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Story Önizleme · 9:16',
            textAlign: TextAlign.center,
            style: AppTypography.serif(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // PNG yakalama için RepaintBoundary
          Center(
            child: RepaintBoundary(
              key: _repaintKey,
              child: StoryCard(
                quoteText: widget.quote.text,
                bookKey: widget.quote.bookId,
                bookTitle: bookTitle,
                bookAuthor: bookAuthor,
                coverUrl: widget.book?.coverUrl,
                page: widget.quote.page,
                themeIndex: _themeIndex,
                width: 184,
                height: 327,
              ),
            ),
          ),

          // 3'lü tema seçici noktalar (`#dots`)
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(AppColors.storyThemes.length, (index) {
              final themeColors = AppColors.storyThemes[index];
              final isSelected = index == _themeIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _themeIndex = index),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: themeColors.first,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.ink
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Görseli Kaydet & Story'de Paylaş butonları
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isBusy ? null : _saveToGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sand,
                    foregroundColor: AppColors.ink,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Görseli Kaydet',
                    style: AppTypography.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isBusy ? null : _shareStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terra,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Story’de Paylaş',
                    style: AppTypography.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
