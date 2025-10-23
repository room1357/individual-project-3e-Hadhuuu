// lib/models/achievement.dart

import 'package:flutter/material.dart'; // Impor untuk IconData
import 'package:hive/hive.dart';

part 'achievement.g.dart';

// Enum untuk tipe kriteria achievement
enum AchievementType {
  // Berdasarkan Level Pemain
  reachLevel,
  // Berdasarkan jumlah transaksi
  addExpenseCountTotal, // Total transaksi seumur hidup
  addExpenseCountSession, // (Belum dipakai) Transaksi dalam satu sesi
  // Berdasarkan Pengeluaran
  spendInCategoryTotal, // Total uang dihabiskan di 1 kategori
  spendTotal, // Total uang dihabiskan seumur hidup
  // Berdasarkan Kebiasaan (Lebih Kompleks, simpan untuk nanti)
  // saveStreak, // Berhasil hemat N hari
  // budgetAdherence, // Patuh budget N kali
}

@HiveType(typeId: 2) // ID Tipe 2 (Expense=0, PlayerStats=1)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id; // ID unik (misal: 'level_5', 'foodie_bronze')

  @HiveField(1)
  final String name; // Nama Lencana (misal: "Petualang Lv. 5")

  @HiveField(2)
  final String description; // Penjelasan cara mendapatkannya

  @HiveField(3)
  final String iconName; // Nama ikon Material (misal: 'star_rounded')

  @HiveField(4)
  final Color color; // Warna utama lencana

  @HiveField(5)
  final AchievementType criteriaType; // Tipe syarat

  @HiveField(6)
  final dynamic criteriaValue; // Nilai syarat (bisa int atau String (categoryId))

  @HiveField(7)
  bool isUnlocked; // Status terkunci/terbuka

  // Constructor
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName, // Kita simpan nama ikonnya saja
    required this.color,
    required this.criteriaType,
    required this.criteriaValue,
    this.isUnlocked = false,
  });

  // Helper untuk mendapatkan IconData dari nama string
  IconData get iconData {
    // Daftar mapping nama string ke IconData (bisa diperluas)
    const iconMap = {
      'star_rounded': Icons.star_rounded,
      'emoji_events_rounded': Icons.emoji_events_rounded,
      'military_tech_rounded': Icons.military_tech_rounded,
      'local_fire_department_rounded': Icons.local_fire_department_rounded,
      'savings_rounded': Icons.savings_rounded,
      'restaurant_menu_rounded': Icons.restaurant_menu_rounded,
      'shopping_bag_rounded': Icons.shopping_bag_rounded,
      'checklist_rtl_rounded': Icons.checklist_rtl_rounded,
    };
    return iconMap[iconName] ?? Icons.help_outline_rounded; // Default jika nama tidak ketemu
  }
}