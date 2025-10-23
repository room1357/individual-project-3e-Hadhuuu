// lib/services/game_service.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/player_stats.dart';
import 'achievement_service.dart'; // <-- 1. Impor Achievement Service

class GameService {
  final Box<PlayerStats> _statsBox = Hive.box<PlayerStats>('playerStats');
  late final ValueNotifier<PlayerStats> playerStats;

  GameService() {
    if (_statsBox.isEmpty) {
      final defaultStats = PlayerStats(level: 1, xp: 0);
      _statsBox.put(0, defaultStats);
    }
    playerStats = ValueNotifier<PlayerStats>(_statsBox.get(0)!);
  }

  void addExperience(int amount) {
    final stats = playerStats.value;
    stats.xp += amount;
    bool hasLeveledUp = false;

    while (stats.xp >= stats.requiredXp) {
      hasLeveledUp = true;
      stats.xp -= stats.requiredXp;
      stats.level += 1;
    }

    stats.save();
    playerStats.value = PlayerStats(level: stats.level, xp: stats.xp);
    
    if (hasLeveledUp) {
      print('SELAMAT! ANDA NAIK KE LEVEL ${stats.level}!');
      // --- 2. PANGGIL CHECK ACHIEVEMENTS SETELAH LEVEL UP ---
      achievementService.checkAchievements();
      // ----------------------------------------------------
    }
    // Panggil juga setelah menambah XP biasa, siapa tahu ada
    // achievement berbasis total XP atau lainnya
    achievementService.checkAchievements();
  }
}

final gameService = GameService();