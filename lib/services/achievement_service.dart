// lib/services/achievement_service.dart

import 'dart:async'; // Untuk StreamController
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/achievement.dart';
import '../models/expense.dart';
import '../models/player_stats.dart';
import '../services/expense_service.dart'; // Untuk akses data expense
import '../services/game_service.dart'; // Untuk akses data level/xp
import '../theme/app_theme.dart'; // Untuk warna default

class AchievementService {
  // Kotak Hive untuk menyimpan ID yang sudah terbuka
  late final Box<String> _unlockedBox;

  // Daftar SEMUA achievement yang mungkin ada di game
  final List<Achievement> _allAchievements = _defineAllAchievements();

  // Notifier untuk UI (menyimpan list achievement + status unlocked)
  final ValueNotifier<List<Achievement>> achievementsNotifier = ValueNotifier([]);

  // StreamController untuk notifikasi pop-up
  final StreamController<Achievement> _newlyUnlockedController = StreamController.broadcast();
  Stream<Achievement> get newlyUnlockedAchievementStream => _newlyUnlockedController.stream;

  // Constructor dipanggil dari main.dart
  void initialize() {
    _unlockedBox = Hive.box<String>('unlockedAchievements');
    _loadAchievements(); // Muat status dari Hive saat service dimulai
  }

  // Memuat status unlocked dari Hive dan update notifier
  void _loadAchievements() {
    final unlockedIds = _unlockedBox.values.toSet(); // Ambil semua ID yg tersimpan
    final currentList = _allAchievements.map((ach) {
      ach.isUnlocked = unlockedIds.contains(ach.id); // Update status isUnlocked
      return ach;
    }).toList();
    achievementsNotifier.value = currentList;
  }

  // --- FUNGSI UTAMA: CEK SEMUA ACHIEVEMENT ---
  void checkAchievements() {
    // Ambil data game state terbaru
    final PlayerStats currentStats = gameService.playerStats.value;
    final List<Expense> allExpenses = expenseService.expenses.value;
    final int totalExpenseCount = allExpenses.length;
    final double totalSpendAmount = allExpenses.fold(0.0, (sum, e) => sum + e.amount);
    
    // Map untuk total pengeluaran per kategori
    Map<String, double> spendPerCategory = {};
    for (var exp in allExpenses) {
      spendPerCategory[exp.categoryId] = (spendPerCategory[exp.categoryId] ?? 0) + exp.amount;
    }

    bool didUnlockAny = false; // Flag jika ada yg baru terbuka

    // Loop melalui SEMUA achievement
    for (var ach in _allAchievements) {
      // Lewati jika sudah terbuka
      if (ach.isUnlocked) continue;

      // Cek kriteria berdasarkan tipe
      bool conditionMet = false;
      switch (ach.criteriaType) {
        case AchievementType.reachLevel:
          conditionMet = currentStats.level >= ach.criteriaValue;
          break;
        case AchievementType.addExpenseCountTotal:
          conditionMet = totalExpenseCount >= ach.criteriaValue;
          break;
        case AchievementType.spendTotal:
          conditionMet = totalSpendAmount >= ach.criteriaValue;
          break;
        case AchievementType.spendInCategoryTotal:
          // criteriaValue di sini adalah Map {'categoryId': 'c1', 'amount': 50000}
          String targetCategoryId = ach.criteriaValue['categoryId'];
          double targetAmount = ach.criteriaValue['amount'];
          conditionMet = (spendPerCategory[targetCategoryId] ?? 0) >= targetAmount;
          break;
        // Tambahkan case lain jika ada tipe baru
        default:
          break;
      }

      // Jika syarat terpenuhi -> UNLOCK!
      if (conditionMet) {
        ach.isUnlocked = true;
        _unlockedBox.put(ach.id, ach.id); // Simpan ID ke Hive
        _newlyUnlockedController.add(ach); // Kirim sinyal ke UI untuk pop-up
        didUnlockAny = true;
        print('ACHIEVEMENT UNLOCKED: ${ach.name}');
      }
    }

    // Jika ada achievement baru, update notifier agar UI (layar achievement) refresh
    if (didUnlockAny) {
      _loadAchievements();
    }
  }

  // Dispose stream controller saat tidak dibutuhkan (meskipun service ini singleton)
  void dispose() {
    _newlyUnlockedController.close();
  }
}

// --- DAFTAR SEMUA ACHIEVEMENT DI SINI ---
List<Achievement> _defineAllAchievements() {
  return [
    // Level Achievements
    Achievement(
      id: 'level_5',
      name: 'Petualang Lv. 5',
      description: 'Capai Level 5.',
      iconName: 'military_tech_rounded',
      color: AppColors.primaryAccent,
      criteriaType: AchievementType.reachLevel,
      criteriaValue: 5,
    ),
    Achievement(
      id: 'level_10',
      name: 'Veteran Lv. 10',
      description: 'Capai Level 10.',
      iconName: 'military_tech_rounded',
      color: AppColors.secondaryAccent,
      criteriaType: AchievementType.reachLevel,
      criteriaValue: 10,
    ),

    // Transaction Count Achievements
    Achievement(
      id: 'first_quest',
      name: 'Misi Pertama Selesai!',
      description: 'Catat pengeluaran pertamamu.',
      iconName: 'checklist_rtl_rounded',
      color: AppColors.accentLime,
      criteriaType: AchievementType.addExpenseCountTotal,
      criteriaValue: 1,
    ),
    Achievement(
      id: 'ten_quests',
      name: 'Penyelesai 10 Misi',
      description: 'Catat 10 pengeluaran.',
      iconName: 'checklist_rtl_rounded',
      color: AppColors.primaryAccent,
      criteriaType: AchievementType.addExpenseCountTotal,
      criteriaValue: 10,
    ),
     Achievement(
      id: 'fifty_quests',
      name: 'Master 50 Misi',
      description: 'Catat 50 pengeluaran.',
      iconName: 'emoji_events_rounded',
      color: AppColors.accentFieryOrange,
      criteriaType: AchievementType.addExpenseCountTotal,
      criteriaValue: 50,
    ),

    // Spending Achievements
     Achievement(
      id: 'first_spend',
      name: 'Koin Pertama',
      description: 'Habiskan Rp 10.000 pertamamu.',
      iconName: 'savings_rounded',
      color: Colors.yellow.shade700,
      criteriaType: AchievementType.spendTotal,
      criteriaValue: 10000.0,
    ),
    Achievement(
      id: 'big_spender_1M',
      name: 'Sultan Awal',
      description: 'Habiskan total Rp 1.000.000.',
      iconName: 'savings_rounded',
      color: AppColors.secondaryAccent,
      criteriaType: AchievementType.spendTotal,
      criteriaValue: 1000000.0,
    ),

    // Category Specific Achievements
    Achievement(
      id: 'foodie_bronze',
      name: 'Jajanan Pertama',
      description: 'Habiskan Rp 50.000 untuk Makanan & Minuman.',
      iconName: 'restaurant_menu_rounded',
      color: Colors.orange.shade300,
      criteriaType: AchievementType.spendInCategoryTotal,
      criteriaValue: {'categoryId': 'c1', 'amount': 50000.0},
    ),
     Achievement(
      id: 'gamer_bronze',
      name: 'Pemburu Diskon Steam',
      description: 'Habiskan Rp 100.000 untuk Hiburan & Game.',
      iconName: 'sports_esports_rounded',
      color: AppColors.secondaryAccent,
      criteriaType: AchievementType.spendInCategoryTotal,
      criteriaValue: {'categoryId': 'c4', 'amount': 100000.0},
    ),
    // ... Tambahkan achievement lainnya di sini
  ];
}

// Buat satu instance global (Singleton)
final achievementService = AchievementService();