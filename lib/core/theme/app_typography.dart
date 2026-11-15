import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Mockup'taki Fraunces (serif) ve Inter (sans-serif) tipografi sistemi.
class AppTypography {
  AppTypography._();

  static TextStyle serif({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.ink,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      height: height,
    );
  }

  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.ink,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: fontFeatures,
    );
  }

  /// Sayfa ana başlığı (`font-serif text-[26px] font-bold text-ink leading-tight`)
  static TextStyle get pageTitle => serif(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  /// Bölüm başlığı (`font-serif text-xl font-bold text-ink`)
  static TextStyle get sectionTitle => serif(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// Bottom sheet başlığı (`font-serif text-2xl font-bold text-ink`)
  static TextStyle get sheetTitle => serif(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// Alıntı italik metni (`font-serif italic text-[17px] leading-relaxed text-ink`)
  static TextStyle get quoteBody => serif(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.6,
      );
}
