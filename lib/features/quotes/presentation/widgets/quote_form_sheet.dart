import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../home/domain/book.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/quote.dart';
import '../providers/quotes_providers.dart';

/// Mockup'taki `#quoteModal` (Yeni Alıntı / Alıntı Düzenle + Gerçek OCR) bottom sheet bileşeni.
class QuoteFormSheet extends ConsumerStatefulWidget {
  final Quote? existingQuote;

  const QuoteFormSheet({
    super.key,
    this.existingQuote,
  });

  static Future<void> show(BuildContext context, {Quote? existingQuote}) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => QuoteFormSheet(existingQuote: existingQuote),
    );
  }

  @override
  ConsumerState<QuoteFormSheet> createState() => _QuoteFormSheetState();
}

class _QuoteFormSheetState extends ConsumerState<QuoteFormSheet> {
  late final TextEditingController _pageCtrl;
  late final TextEditingController _textCtrl;
  late final TextEditingController _noteCtrl;

  String? _selectedBookId;
  QuoteSource _source = QuoteSource.manual;
  bool _isScanningOcr = false;
  bool _ocrDone = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingQuote;
    final dash = ref.read(homeDashboardProvider).valueOrNull;
    final activeBook = dash?.activeBook;

    _selectedBookId = existing?.bookId ?? activeBook?.id;
    final initialPage = existing != null
        ? existing.page
        : (activeBook?.currentPage ?? 1);

    _pageCtrl = TextEditingController(
      text: initialPage > 0 ? initialPage.toString() : '',
    );
    _textCtrl = TextEditingController(text: existing?.text ?? '');
    _noteCtrl = TextEditingController(text: existing?.note ?? '');
    _source = existing?.source ?? QuoteSource.manual;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _textCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _runOcr({ImageSource imageSource = ImageSource.camera}) async {
    if (_isScanningOcr) return;
    setState(() {
      _isScanningOcr = true;
      _ocrDone = false;
    });

    try {
      final scanned = await ref
          .read(ocrServiceProvider)
          .scanText(source: imageSource);
      if (!mounted) return;

      if (scanned != null && scanned.isNotEmpty) {
        setState(() {
          _textCtrl.text = scanned;
          _source = QuoteSource.ocr;
          _ocrDone = true;
        });
        AppToast.show(context, 'OCR tamamlandı ✨');
      } else {
        AppToast.show(context, 'Görselde metin algılanamadı');
      }
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Kamera/OCR başlatılamadı');
    } finally {
      if (mounted) {
        setState(() => _isScanningOcr = false);
      }
    }
  }

  Future<void> _saveQuote() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      AppToast.show(context, 'Önce bir alıntı yaz ✍️');
      return;
    }

    final uid = ref.read(currentUserIdProvider);
    if (uid == null || _isSaving) return;

    final bookId = _selectedBookId ?? 'dune';
    final page = int.tryParse(_pageCtrl.text.trim()) ?? 0;
    final note = _noteCtrl.text.trim();

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(quotesRepositoryProvider);
      if (widget.existingQuote != null) {
        final updated = widget.existingQuote!.copyWith(
          bookId: bookId,
          page: page,
          text: text,
          note: note,
          source: _source,
        );
        await repo.updateQuote(uid, updated);
      } else {
        final created = Quote(
          id: '',
          bookId: bookId,
          page: page,
          text: text,
          note: note,
          source: _source,
          createdAt: DateTime.now(),
        );
        await repo.addQuote(uid, created);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(
        context,
        widget.existingQuote != null
            ? 'Alıntı güncellendi 💬'
            : 'Alıntı kaydedildi 💬',
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Alıntı kaydedilirken hata oluştu');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dash = ref.watch(homeDashboardProvider).valueOrNull;
    final allBooks = dash?.allBooks ?? const <Book>[];
    final activeBookId = dash?.activeBook?.id;

    // Kütüphane boşsa varsayılan seçenek
    final dropdownBooks = allBooks.isNotEmpty
        ? allBooks
        : [
            const Book(
              id: 'dune',
              title: 'Dune',
              author: 'Frank Herbert',
              totalPages: 320,
              currentPage: 184,
            ),
          ];

    final effectiveBookId = dropdownBooks.any((b) => b.id == _selectedBookId)
        ? _selectedBookId!
        : dropdownBooks.first.id;

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existingQuote != null ? 'Alıntıyı Düzenle' : 'Yeni Alıntı',
            style: AppTypography.sheetTitle,
          ),
          const SizedBox(height: 16),

          // Kitap (2/3) + Sayfa (1/3) (`grid-cols-3 gap-3`)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitap',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: effectiveBookId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: dropdownBooks.map((b) {
                        final isCurrent = b.id == activeBookId;
                        return DropdownMenuItem<String>(
                          value: b.id,
                          child: Text(
                            '${isCurrent ? '📖 Şu an: ' : ''}${b.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(fontSize: 13.5),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        final chosen = dropdownBooks.firstWhere(
                          (b) => b.id == val,
                        );
                        setState(() {
                          _selectedBookId = val;
                          if (chosen.currentPage > 0) {
                            _pageCtrl.text = chosen.currentPage.toString();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sayfa',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _pageCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTypography.sans(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // OCR Tarama Butonu (`border-2 border-dashed border-sage text-sage`)
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _runOcr(imageSource: ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.sage,
                        width: 1.6,
                      ),
                      color: AppColors.sage.withOpacity(0.06),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isScanningOcr)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.sage,
                            ),
                          )
                        else
                          const Icon(
                            LucideIcons.camera,
                            size: 16,
                            color: AppColors.sage,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isScanningOcr
                              ? 'Sayfa taranıyor…'
                              : (_ocrDone
                                  ? '✓ Metin algılandı'
                                  : '📸 Kameradan Tara (OCR)'),
                          style: AppTypography.sans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Galeriden Seç (OCR)',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _runOcr(imageSource: ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sage, width: 1.6),
                      color: AppColors.sage.withOpacity(0.06),
                    ),
                    child: const Icon(
                      LucideIcons.image,
                      size: 18,
                      color: AppColors.sage,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Alıntı Metni (`font-serif italic`)
          const SizedBox(height: 16),
          Text(
            'Alıntı Metni',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _textCtrl,
            maxLines: 4,
            style: AppTypography.serif(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: AppColors.ink,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: 'Etkilendiğin cümleyi yaz ya da tara…',
              hintStyle: AppTypography.serif(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: AppColors.ink.withOpacity(0.4),
              ),
            ),
          ),

          // Kişisel Not / İnceleme
          const SizedBox(height: 12),
          Text(
            'Kişisel Not / İnceleme',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            style: AppTypography.sans(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Bu cümle sana ne hissettirdi?',
              hintStyle: AppTypography.sans(
                fontSize: 13.5,
                color: AppColors.ink.withOpacity(0.4),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sand,
                    foregroundColor: AppColors.ink,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Vazgeç',
                    style: AppTypography.sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terra,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Kaydediliyor…' : 'Kaydet',
                    style: AppTypography.sans(
                      fontSize: 15,
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
