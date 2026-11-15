import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/book_cover.dart';
import '../../domain/book.dart';
import '../providers/home_providers.dart';

/// Yeni kitap ekleme & Google Books hızlı arama bottom sheet bileşeni.
class AddBookSheet extends ConsumerStatefulWidget {
  const AddBookSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => const AddBookSheet(),
    );
  }

  @override
  ConsumerState<AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends ConsumerState<AddBookSheet> {
  final _searchCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController(text: '250');

  static const _genres = [
    'Bilim Kurgu',
    'Felsefe',
    'Psikoloji',
    'Klasikler',
    'Roman',
  ];

  String _selectedGenre = _genres.first;
  BookStatus _selectedStatus = BookStatus.reading;
  String? _selectedCoverUrl;
  String? _selectedGoogleBooksId;

  bool _isSearching = false;
  bool _isSaving = false;
  List<Book> _searchResults = const [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _pagesCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchGoogleBooks(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() => _searchResults = const []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      const apiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');
      final keyParam = apiKey.isNotEmpty ? '&key=$apiKey' : '';
      final uri = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeQueryComponent(trimmed)}&maxResults=6&printType=books$keyParam',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>?) ?? const [];
        final parsed = items.map((raw) {
          final item = raw as Map<String, dynamic>;
          final info = (item['volumeInfo'] as Map<String, dynamic>?) ?? const {};
          final authors = (info['authors'] as List<dynamic>?) ?? const [];
          final categories = (info['categories'] as List<dynamic>?) ?? const [];
          final imageLinks =
              (info['imageLinks'] as Map<String, dynamic>?) ?? const {};
          final thumb = (imageLinks['thumbnail'] as String?)
              ?.replaceFirst('http://', 'https://');

          return Book(
            id: (item['id'] as String?) ?? '',
            googleBooksId: item['id'] as String?,
            title: (info['title'] as String?) ?? 'İsimsiz Kitap',
            author: authors.isNotEmpty
                ? authors.first.toString()
                : 'Bilinmeyen Yazar',
            genre: _mapGenre(
              categories.isNotEmpty ? categories.first.toString() : '',
            ),
            totalPages: (info['pageCount'] as num?)?.toInt() ?? 240,
            currentPage: 0,
            coverUrl: thumb,
            status: BookStatus.reading,
          );
        }).toList();

        if (mounted) {
          setState(() => _searchResults = parsed);
        }
      }
    } catch (_) {
      // Çevrim dışıysa manuel ekleme formu kullanılabilir
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  String _mapGenre(String rawCategory) {
    final lower = rawCategory.toLowerCase();
    if (lower.contains('fiction') && lower.contains('science')) {
      return 'Bilim Kurgu';
    }
    if (lower.contains('philosophy') || lower.contains('felsefe')) {
      return 'Felsefe';
    }
    if (lower.contains('psychology') || lower.contains('psikoloji')) {
      return 'Psikoloji';
    }
    if (lower.contains('classic') || lower.contains('klasik')) {
      return 'Klasikler';
    }
    return _selectedGenre;
  }

  void _selectSearchResult(Book b) {
    setState(() {
      _titleCtrl.text = b.title;
      _authorCtrl.text = b.author;
      _pagesCtrl.text = (b.totalPages > 0 ? b.totalPages : 240).toString();
      _selectedGenre = _genres.contains(b.genre) ? b.genre : _genres.first;
      _selectedCoverUrl = b.coverUrl;
      _selectedGoogleBooksId = b.googleBooksId;
      _searchResults = const [];
    });
  }

  Future<void> _saveBook() async {
    final title = _titleCtrl.text.trim();
    final author = _authorCtrl.text.trim();
    final totalPages = int.tryParse(_pagesCtrl.text.trim()) ?? 0;

    if (title.isEmpty) {
      AppToast.show(context, 'Kitap adını gir 📚');
      return;
    }
    if (totalPages <= 0) {
      AppToast.show(context, 'Geçerli bir sayfa sayısı gir');
      return;
    }

    final uid = ref.read(currentUserIdProvider);
    if (uid == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final book = Book(
        id: '',
        title: title,
        author: author.isEmpty ? 'Bilinmeyen Yazar' : author,
        genre: _selectedGenre,
        totalPages: totalPages,
        currentPage: 0,
        status: _selectedStatus,
        coverUrl: _selectedCoverUrl,
        googleBooksId: _selectedGoogleBooksId,
        startedAt: DateTime.now(),
      );

      await ref.read(booksRepositoryProvider).addBook(
            uid,
            book,
            setAsActive: _selectedStatus == BookStatus.reading,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(
        context,
        _selectedStatus == BookStatus.reading
            ? 'Aktif kitap olarak eklendi 📖'
            : 'Okuma listene eklendi 📚',
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Kitap eklenirken hata oluştu');
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
          Text('Kitap Ekle', style: AppTypography.sheetTitle),
          const SizedBox(height: 4),
          Text(
            'Google Books ile ara ya da bilgileri manuel gir',
            style: AppTypography.sans(
              fontSize: 13,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Google Books Arama
          TextField(
            controller: _searchCtrl,
            onSubmitted: _searchGoogleBooks,
            decoration: InputDecoration(
              hintText: 'Google Books’ta kitap veya yazar ara…',
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.terra,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(LucideIcons.arrowRight, size: 18),
                      onPressed: () => _searchGoogleBooks(_searchCtrl.text),
                    ),
            ),
          ),

          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectSearchResult(item),
                    child: Container(
                      width: 210,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.sand),
                      ),
                      child: Row(
                        children: [
                          BookCover(
                            bookKey: item.id,
                            title: item.title,
                            coverUrl: item.coverUrl,
                            width: 48,
                            height: 72,
                            borderRadius: 6,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.serif(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.sans(
                                    fontSize: 11,
                                    color: AppColors.ink.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.totalPages} sf.',
                                  style: AppTypography.sans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.terra,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),
          Text(
            'Kitap Adı',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(hintText: 'Örn: Dune'),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yazar',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _authorCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Örn: Frank Herbert',
                      ),
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
                      'Toplam Sayfa',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _pagesCtrl,
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
            'Tür',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _genres.map((g) {
                final on = g == _selectedGenre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _selectedGenre = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: on ? AppColors.ink : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: on ? AppColors.ink : AppColors.sand,
                        ),
                      ),
                      child: Text(
                        g,
                        style: AppTypography.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: on ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatusChip(
                  label: '📖 Şu An Okuyorum',
                  selected: _selectedStatus == BookStatus.reading,
                  onTap: () =>
                      setState(() => _selectedStatus = BookStatus.reading),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusChip(
                  label: '🔖 Okuma Listem',
                  selected: _selectedStatus == BookStatus.wishlist,
                  onTap: () =>
                      setState(() => _selectedStatus = BookStatus.wishlist),
                ),
              ),
            ],
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
                  onPressed: _isSaving ? null : _saveBook,
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
                    _isSaving ? 'Kaydediliyor…' : 'Kitabı Ekle',
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

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.terra.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.terra : AppColors.sand,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.terra : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
