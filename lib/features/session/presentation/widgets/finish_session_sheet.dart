import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/reading_calculator.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../home/domain/book.dart';
import '../providers/session_providers.dart';

/// Mockup'taki `#finModal` (Seans Özeti) bottom sheet bileşeni.
class FinishSessionSheet extends ConsumerStatefulWidget {
  final Book activeBook;
  final int durationSeconds;
  final DateTime startedAt;

  const FinishSessionSheet({
    super.key,
    required this.activeBook,
    required this.durationSeconds,
    required this.startedAt,
  });

  static Future<void> show({
    required BuildContext context,
    required Book activeBook,
    required int durationSeconds,
    required DateTime startedAt,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => FinishSessionSheet(
        activeBook: activeBook,
        durationSeconds: durationSeconds,
        startedAt: startedAt,
      ),
    );
  }

  @override
  ConsumerState<FinishSessionSheet> createState() => _FinishSessionSheetState();
}

class _FinishSessionSheetState extends ConsumerState<FinishSessionSheet> {
  final TextEditingController _pagesCtrl = TextEditingController(text: '12');
  int _pagesRead = 12;
  bool _isSaving = false;

  @override
  void dispose() {
    _pagesCtrl.dispose();
    super.dispose();
  }

  void _onPagesChanged(String raw) {
    setState(() {
      _pagesRead = int.tryParse(raw) ?? 0;
    });
  }

  Future<void> _saveSession() async {
    if (_pagesRead < 1) {
      AppToast.show(context, 'Sayfa sayısı gir');
      return;
    }

    final uid = ref.read(currentUserIdProvider);
    if (uid == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(sessionRepositoryProvider).saveCompletedSession(
            uid: uid,
            activeBook: widget.activeBook,
            durationSeconds: widget.durationSeconds,
            pagesRead: _pagesRead,
            startedAt: widget.startedAt,
            endedAt: DateTime.now(),
          );

      await ref.read(stopwatchProvider.notifier).reset();

      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(context, 'Seans kaydedildi · +$_pagesRead sayfa ✅');
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Seans kaydedilirken hata oluştu');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDuration = ReadingCalculator.formatStopwatch(
      widget.durationSeconds,
    );
    final summaryText = ReadingCalculator.formatSessionSummaryPreview(
      durationSeconds: widget.durationSeconds,
      pagesRead: _pagesRead,
    );

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seans Özeti',
            style: AppTypography.sheetTitle,
          ),
          const SizedBox(height: 4),
          Text(
            'Toplam süre: $formattedDuration',
            style: AppTypography.sans(
              fontSize: 14,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Bu seansta kaç sayfa okudun?',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _pagesCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onPagesChanged,
            style: AppTypography.sans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),

          // Yeşil hız özet kutusu: `rounded-2xl bg-sage/15 border border-sage/30 p-4 text-center`
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sage.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.sage.withOpacity(0.30),
              ),
            ),
            child: Text(
              summaryText,
              textAlign: TextAlign.center,
              style: AppTypography.serif(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
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
                  onPressed: _isSaving ? null : _saveSession,
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
                    _isSaving ? 'Kaydediliyor…' : 'Seansı Kaydet',
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
