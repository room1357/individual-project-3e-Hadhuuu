// lib/screens/achievements_screen.dart

import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hall of Glory'),
      ),
      body: ValueListenableBuilder<List<Achievement>>(
        valueListenable: achievementService.achievementsNotifier,
        builder: (context, achievements, child) {
          if (achievements.isEmpty) {
            return const Center(child: Text('Tidak ada lencana tersedia.'));
          }

          // Pisahkan yang sudah terbuka dan belum
          final unlocked = achievements.where((a) => a.isUnlocked).toList();
          final locked = achievements.where((a) => !a.isUnlocked).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unlocked.isNotEmpty) ...[
                _buildSectionTitle('Lencana Terkumpul (${unlocked.length})', Icons.emoji_events_rounded, AppColors.accentLime),
                _buildAchievementGrid(unlocked),
                const SizedBox(height: 24),
              ],
              if (locked.isNotEmpty) ...[
                 _buildSectionTitle('Tantangan Berikutnya (${locked.length})', Icons.lock_outline_rounded, AppColors.textLight),
                _buildAchievementGrid(locked),
              ],
            ],
          );
        },
      ),
    );
  }

  // Judul Section
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
     return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Grid untuk menampilkan lencana
  Widget _buildAchievementGrid(List<Achievement> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  // Kartu untuk satu lencana
  Widget _buildAchievementCard(Achievement achievement) {
    final color = achievement.isUnlocked ? achievement.color : AppColors.textLight.withOpacity(0.3);
    // Hapus iconColor, warna ikon = warna lencana

    return Card(
      elevation: achievement.isUnlocked ? 4 : 1,
      shadowColor: color.withOpacity(0.5),
      color: achievement.isUnlocked ? AppColors.card : AppColors.card.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran Lencana
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(achievement.isUnlocked ? 0.2 : 0.1),
                border: Border.all(color: color, width: 2)
              ),
              child: Icon(
                // Tampilkan ikon asli tapi redup jika terkunci
                achievement.iconData,
                size: 36,
                color: achievement.isUnlocked ? color : color.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            // Nama Lencana
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked ? AppColors.textDark : AppColors.textLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4), // Beri sedikit jarak
            // --- PERBAIKAN: TAMPILKAN DESKRIPSI UNTUK SEMUA ---
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                // Buat lebih redup jika terkunci
                color: achievement.isUnlocked ? AppColors.textLight : AppColors.textLight.withOpacity(0.7),
              ),
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
            ),
            // --- BATAS PERBAIKAN ---
          ],
        ),
      ),
    );
  }
}