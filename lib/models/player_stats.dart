// lib/models/player_stats.dart

import 'package:hive/hive.dart';

part 'player_stats.g.dart';

@HiveType(typeId: 1) // ID Tipe 1 (Expense adalah 0)
class PlayerStats extends HiveObject {
  
  @HiveField(0)
  int level;

  @HiveField(1)
  int xp;

  PlayerStats({
    required this.level,
    required this.xp,
  });

  // Logika "Required XP" ada di sini
  // Kita buat formula yang sedikit naik: (Level * 500) + 1000
  // Lv 1 -> 1500 XP
  // Lv 2 -> 2000 XP
  // Lv 3 -> 2500 XP
  int get requiredXp => (level * 500) + 1000;
}