import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_toast.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../home/presentation/providers/home_providers.dart';

/// Kullanıcı adı, yıllık hedef, Google/Apple ile hesabı bağlama (`linkWithCredential`)
/// ve çıkış yapma işlemlerini içeren ayarlar sheet'i.
class SettingsSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const SettingsSheet({
    super.key,
    required this.profile,
  });

  static Future<void> show(BuildContext context, UserProfile profile) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => SettingsSheet(profile: profile),
    );
  }

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _goalCtrl;
  bool _isSaving = false;
  bool _isAuthBusy = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.displayName);
    _goalCtrl = TextEditingController(
      text: widget.profile.yearlyGoal.toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null || _isSaving) return;

    final name = _nameCtrl.text.trim();
    final goal = int.tryParse(_goalCtrl.text.trim()) ?? 25;

    setState(() => _isSaving = true);
    try {
      await ref.read(booksRepositoryProvider).updateUserProfile(
            uid,
            displayName: name.isEmpty ? 'Okur' : name,
            yearlyGoal: goal.clamp(1, 500),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(context, 'Profil ve hedef güncellendi ✨');
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Güncellenirken hata oluştu');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _linkGoogle() async {
    if (_isAuthBusy) return;
    setState(() => _isAuthBusy = true);
    try {
      final user = await ref.read(authRepositoryProvider).linkWithGoogle();
      if (!mounted) return;
      if (user != null) {
        AppToast.show(context, 'Google hesabı başarıyla bağlandı ✅');
      }
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Google hesabı bağlanamadı');
    } finally {
      if (mounted) setState(() => _isAuthBusy = false);
    }
  }

  Future<void> _linkApple() async {
    if (_isAuthBusy) return;
    setState(() => _isAuthBusy = true);
    try {
      final user = await ref.read(authRepositoryProvider).linkWithApple();
      if (!mounted) return;
      if (user != null) {
        AppToast.show(context, 'Apple hesabı başarıyla bağlandı ✅');
      }
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Apple hesabı bağlanamadı');
    } finally {
      if (mounted) setState(() => _isAuthBusy = false);
    }
  }

  Future<void> _signOut() async {
    if (_isAuthBusy) return;
    setState(() => _isAuthBusy = true);
    try {
      await ref.read(authRepositoryProvider).signOutAndStartAnonymous();
      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(context, 'Oturum kapatıldı');
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Çıkış yapılırken hata oluştu');
    } finally {
      if (mounted) setState(() => _isAuthBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateChangesProvider).valueOrNull;
    final isAnon = authUser?.isAnonymous ?? true;
    final email = authUser?.email;

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil & Ayarlar', style: AppTypography.sheetTitle),
          const SizedBox(height: 16),

          Text(
            'Adın / Hitap',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Okur'),
          ),

          const SizedBox(height: 14),
          Text(
            '${DateTime.now().year} Yıllık Kitap Hedefi',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _goalCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),

          // Hesap Bağlama Bölümü (linkWithCredential)
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.sand),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAnon ? LucideIcons.shieldAlert : LucideIcons.shieldCheck,
                      size: 16,
                      color: isAnon ? AppColors.terra : AppColors.sage,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAnon
                            ? 'Anonim Oturum (Verilerini yedeklemek için bağla)'
                            : 'Bağlı Hesap: ${email ?? 'Doğrulandı'}',
                        style: AppTypography.sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isAnon) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isAuthBusy ? null : _linkGoogle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.sand),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(LucideIcons.globe, size: 15),
                          label: Text(
                            'Google ile Bağla',
                            style: AppTypography.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isAuthBusy ? null : _linkApple,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.sand),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(LucideIcons.smartphone, size: 15),
                          label: Text(
                            'Apple ile Bağla',
                            style: AppTypography.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _isAuthBusy ? null : _signOut,
                    icon: const Icon(
                      LucideIcons.logOut,
                      size: 14,
                      color: AppColors.terra,
                    ),
                    label: Text(
                      'Çıkış Yap',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.terra,
                      ),
                    ),
                  ),
                ),
              ],
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
                    'Kaydet',
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
