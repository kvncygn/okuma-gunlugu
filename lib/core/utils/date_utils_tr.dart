/// Türkçe tarih, gün adı ve selamlama yardımcıları.
class DateUtilsTr {
  DateUtilsTr._();

  static const List<String> _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> _weekdaysFull = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static const List<String> _weekdaysShort = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  /// Kullanıcının yerel gününü `'yyyy-MM-dd'` formatında döndürür.
  static String toLocalDayKey(DateTime date) {
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Mockup üst tarih formatı: `"Salı, 20 Ekim"`
  static String formatHeaderDate(DateTime date) {
    final local = date.toLocal();
    final weekday = _weekdaysFull[local.weekday - 1];
    final month = _months[local.month - 1];
    return '$weekday, ${local.day} $month';
  }

  /// Kısa hafta günü adı: `'Pzt'`, `'Sal'`, vb.
  static String shortWeekday(DateTime date) {
    final local = date.toLocal();
    return _weekdaysShort[local.weekday - 1];
  }

  /// Saate göre Türkçe selamlama (`"İyi akşamlar"`, `"Günaydın"`, `"İyi günler"`, `"İyi geceler"`).
  static String greetingForHour(int hour) {
    if (hour >= 6 && hour < 12) return 'Günaydın';
    if (hour >= 12 && hour < 18) return 'İyi günler';
    if (hour >= 18 && hour < 23) return 'İyi akşamlar';
    return 'İyi geceler';
  }

  /// Yıl sonuna kalan gün sayısı: `"yıl sonuna 72 gün"`
  static int daysLeftInYear(DateTime date) {
    final local = date.toLocal();
    final endOfYear = DateTime(local.year, 12, 31);
    final today = DateTime(local.year, local.month, local.day);
    final diff = endOfYear.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }
}
