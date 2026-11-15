import 'package:flutter/material.dart';

/// Mockup'taki tailwind.config ve script sabitlerinden alınan tasarım token'ları.
class AppColors {
  AppColors._();

  // Ana tasarım token'ları (tailwind.config)
  static const Color cream = Color(0xFFFAF7F2);
  static const Color ink = Color(0xFF1E293B);
  static const Color terra = Color(0xFFC2714F);
  static const Color terraLight = Color(0xFFE0A07F);
  static const Color sage = Color(0xFF7C9A87);
  static const Color sand = Color(0xFFEFE8DC);

  // Yardımcı renkler
  static const Color navInactive = Color(0xFF94A3B8);
  static const Color white = Colors.white;

  /// İlerleme çubuğu gradyanı (`bg-gradient-to-r from-terra to-[#E0A07F]`)
  static const LinearGradient terraGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [terra, terraLight],
  );

  /// Mockup `<script>` içindeki `PAL` 8'li kitap kapağı gradyan paleti (`150deg`)
  static const List<List<Color>> coverPalettes = [
    [Color(0xFFC2714F), Color(0xFF7A3E26)],
    [Color(0xFF2E4A62), Color(0xFF1E293B)],
    [Color(0xFFB23A3A), Color(0xFF4A1616)],
    [Color(0xFF7C9A87), Color(0xFF2F4A3A)],
    [Color(0xFFD9A441), Color(0xFF8C5A1B)],
    [Color(0xFF9C6B8E), Color(0xFF3B2338)],
    [Color(0xFF4F7C82), Color(0xFF1B3B40)],
    [Color(0xFF6B5B4B), Color(0xFF2B211A)],
  ];

  /// Mockup `<script>` içindeki `TH` 3'lü Story kartı gradyan teması (`165deg`)
  static const List<List<Color>> storyThemes = [
    [Color(0xFFC2714F), Color(0xFF5A2A18)],
    [Color(0xFF2E4A62), Color(0xFF14202E)],
    [Color(0xFF7C9A87), Color(0xFF24382C)],
  ];
}
