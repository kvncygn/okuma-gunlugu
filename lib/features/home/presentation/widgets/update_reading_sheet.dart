import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/reading_calculator.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../domain/book.dart';
import '../providers/home_providers.dart';

/// Mockup'taki `#pageModal` (Okuma Güncelle) bottom sheet bileşeni.
class UpdateReadingSheet extends ConsumerStatefulWidget {
  final Book book;

  const UpdateReadingSheet({
    super.key,
    required this.book,
  });

  static Future<void> show(BuildContext context, Book book) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => UpdateReadingSheet(book: book),
    );
  }

  @override
  ConsumerState<UpdateReadingSheet> createState() => _UpdateReadingSheetState();
}

class _UpdateReadingSheetState extends ConsumerState<UpdateReadingSheet> {
  late final TextEditingController _controller;
  late int _inputValue;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _inputValue = widget.book.currentPage;
    _controller = TextEditingController(text: _inputValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    final parsed = int.tryParse(raw) ?? 0;
    setState(() {
      _inputValue = ReadingCalculator.clampPage(parsed, widget.book.totalPages);
    });
  }

  void _stepPage(int delta) {
    final nextVal = ReadingCalculator.stepPage(
      _inputValue,
      delta,
      widget.book.totalPages,
    );
    setState(() {
      _inputValue = nextVal;
      _controller.text = nextVal.toString();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  Future<void> _save() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final result = await ref
          .read(booksRepositoryProvider)
          .updateReadingProgress(
            uid: uid,
            book: widget.book,
            newPage: _inputValue,
          );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (result.autoFinished) {
        AppToast.show(context, 'Kitabı bitirdin! 🎉');
      } else if (result.delta > 0) {
        AppToast.show(context, '+${result.delta} sayfa eklendi 📖');
      } else {
        AppToast.show(context, 'İlerleme güncellendi');
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, 'Kaydedilirken hata oluştu');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.book.totalPages;
    final oldPage = widget.book.currentPage;
    final pct = ReadingCalculator.calculatePercentage(_inputValue, total);
    final previewText = ReadingCalculator.formatPageUpdatePreview(
      newPage: _inputValue,
      oldPage: oldPage,
      totalPages: total,
    );

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Okuma Güncelle',
            style: AppTypography.sheetTitle,
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTypography.sans(
                fontSize: 14,
                color: AppColors.ink.withOpacity(0.6),
              ),
              children: [
                TextSpan(text: '${widget.book.title} · son kaldığın sayfa '),
                TextSpan(
                  text: '$oldPage',
                  style: AppTypography.sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // −10 / Sayı Girişi / +10
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                label: '−10',
                onTap: () => _stepPage(-10),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 112,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  onChanged: _onChanged,
                  style: AppTypography.serif(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.sand, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.terra, width: 2),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.sand, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _StepButton(
                label: '+10',
                onTap: () => _stepPage(10),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ProgressBar(
            percentage: pct,
            height: 10,
            useGradient: false,
            solidColor: AppColors.terra,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              previewText,
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 12,
                color: AppColors.ink.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),

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
                  onPressed: _isSaving ? null : _save,
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

class _StepButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StepButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sand,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: AppTypography.sans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
