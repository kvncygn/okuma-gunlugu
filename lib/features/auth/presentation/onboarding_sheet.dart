import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_toast.dart';
import '../../home/domain/book.dart';
import '../../home/presentation/providers/home_providers.dart';

/// İlk açılış karşılama (Onboarding) bottom sheet bileşeni.
class OnboardingSheet extends ConsumerStatefulWidget {
  const OnboardingSheet({super.key});

  static const _kOnboardingCompleted = 'onboarding_completed_v1';

  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final done = prefs.getBool(_kOnboardingCompleted) ?? false;
    if (done) return;

    await AppBottomSheet.show(
      context: context,
      builder: (_) => const OnboardingSheet(),
    );
  }

  @override
  ConsumerState<OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends ConsumerState<OnboardingSheet> {
  final _nameCtrl = TextEditingController(text: 'Okur');
  final _goalCtrl = TextEditingController(text: '25');
  final _bookTitleCtrl = TextEditingController(text: 'Dune');
  final _bookAuthorCtrl = TextEditingController(text: 'Frank Herbert');
  final _bookPagesCtrl = TextEditingController(text: '320');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    _bookTitleCtrl.dispose();
    _bookAuthorCtrl.dispose();
    _bookPagesCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(OnboardingSheet._kOnboardingCompleted, true);

      final uid = ref.read(currentUserIdProvider);
      if (uid != null) {
        final name = _nameCtrl.text.trim().isEmpty
            ? 'Okur'
            : _nameCtrl.text.trim();
        final goal = (int.tryParse(_goalCtrl.text.trim()) ?? 25).clamp(1, 500);
        final repo = ref.read(booksRepositoryProvider);

        await repo.updateUserProfile(
          uid,
          displayName: name,
          yearlyGoal: goal,
        );

        final bookTitle = _bookTitleCtrl.text.trim();
        if (bookTitle.isNotEmpty) {
          final pages =
              (int.tryParse(_bookPagesCtrl.text.trim()) ?? 320).clamp(1, 10000);
          final book = Book(
            id: bookTitle.toLowerCase() == 'dune' ? 'dune' : '',
            title: bookTitle,
            author: _bookAuthorCtrl.text.trim().isEmpty
                ? 'Bilinmeyen Yazar'
                : _bookAuthorCtrl.text.trim(),
            genre: 'Bilim Kurgu',
            totalPages: pages,
            currentPage: bookTitle.toLowerCase() == 'dune' ? 184 : 0,
            status: BookStatus.reading,
            startedAt: DateTime.now(),
          );
          await repo.addBook(uid, book, setAsActive: true);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(context, 'Okuma Günlüğüne hoş geldin! 📖');
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Okuma Günlüğüne Hoş Geldin 👋',
            style: AppTypography.sheetTitle,
          ),
          const SizedBox(height: 4),
          Text(
            'Okuma hedefini ve şu an okuduğun kitabı belirleyerek hemen başla.',
            style: AppTypography.sans(
              fontSize: 13.5,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adın / Hitap',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(controller: _nameCtrl),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yıllık Hedef',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _goalCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Text(
            'Şu An Okuduğun Kitap',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _bookTitleCtrl,
            decoration: const InputDecoration(hintText: 'Kitap Adı'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _bookAuthorCtrl,
                  decoration: const InputDecoration(hintText: 'Yazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _bookPagesCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: 'Sayfa'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terra,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isSaving ? 'Hazırlanıyor…' : 'Okuma Günlüğüme Başla',
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
    );
  }
}
