// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  // Palet Warna Utama: "Arcane Energy" (Dark Mode)
  static const Color background = Color(0xFF1A1B2E); // Deep Indigo
  static const Color card = Color(0xFF2A2D40); // Dark Slate
  static const Color textDark = Color(0xFFF5F5F5); // Light Gray (untuk teks utama)
  static const Color textLight = Color(0xFFB0BEC5); // Medium Gray (untuk sub-teks)

  // Aksen Neon (Energi)
  static const Color primaryAccent = Color(0xFF00E5FF); // Electric Cyan
  static const Color secondaryAccent = Color(0xFFE040FB); // Vibrant Orchid
  static const Color accentLime = Color(0xFFB2FF59); // Vibrant Lime (XP/Positif)
  static const Color accentFieryOrange = Color(0xFFFF6D00); // Fiery Orange (Expense/Negatif)

  // Gradasi
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryAccent, secondaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [accentLime, Color(0xFF76FF03)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFF2F3247), Color(0xFF2A2D40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      brightness: Brightness.dark, // Memberi tahu Flutter ini adalah tema gelap

      // Skema Warna
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAccent,
        brightness: Brightness.dark,
        background: AppColors.background,
        primary: AppColors.primaryAccent, // Cyan
        secondary: AppColors.secondaryAccent, // Orchid
        tertiary: AppColors.accentLime, // Lime
        error: AppColors.accentFieryOrange, // Orange
      ),

      // Tema AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0, // AppBar "menyatu" dengan background
        backgroundColor: AppColors.background,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        iconTheme: IconThemeData(color: AppColors.primaryAccent),
      ),

      // Tema Tombol
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent, // Tombol Cyan
          foregroundColor: Colors.black, // Teks hitam agar kontras
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          // Efek "glow" saat ditekan
          shadowColor: AppColors.primaryAccent.withOpacity(0.8),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tema Card
      cardTheme: CardThemeData(
        elevation: 4,
        color: AppColors.card,
        // Shadow warna-warni untuk efek "glow"
        shadowColor: AppColors.primaryAccent.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // Beri border tipis warna neon
          side: BorderSide(color: AppColors.primaryAccent.withOpacity(0.2), width: 1),
        ),
      ),

      // Tema Input Field
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.card.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontFamily: 'Nunito',
        ),
        prefixIconColor: AppColors.textLight,
        labelStyle: const TextStyle(color: AppColors.textLight)
      ),

      // Tema Dialog/Popup
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryAccent.withOpacity(0.3), width: 1)
        ),
        titleTextStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark),
      ),

      // Tema Chip (untuk filter)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        disabledColor: Colors.grey.shade800,
        selectedColor: AppColors.primaryAccent, // Cyan
        secondarySelectedColor: AppColors.primaryAccent,
        labelStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            color: AppColors.textLight), // Teks abu-abu
        secondaryLabelStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            color: Colors.black), // Teks hitam saat terpilih
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryAccent.withOpacity(0.3)),
        ),
        selectedShadowColor: AppColors.primaryAccent.withOpacity(0.3),
        elevation: 2,
      ),

      // Tema FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.black, // Teks/ikon hitam
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Tema TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold
          )
        )
      ),

      // Tema Divider
      dividerTheme: DividerThemeData(
        color: AppColors.primaryAccent.withOpacity(0.2),
        thickness: 1,
      )
    );
  }
}