// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/player_stats.dart';
import '../models/insight.dart'; // Impor Insight
import '../services/game_service.dart';
import '../services/insight_service.dart'; // Impor Insight Service
import 'login_screen.dart';
import 'expense_list_screen.dart';
import 'category_screen.dart';
import 'settings_screen.dart';
// Hapus import statistics_screen.dart
import 'achievements_screen.dart';
import 'insights_screen.dart'; // Impor Layar Insight Baru
import '../theme/app_theme.dart';
import '../widgets/hover_scale_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInsight = insightService.generateInsights().firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Hub'),
        actions: [
          IconButton(
            onPressed: () { _showLogoutDialog(context); }, // Kembalikan context
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ValueListenableBuilder<PlayerStats>(
            valueListenable: gameService.playerStats,
            builder: (context, stats, child) {
              return _buildPlayerCard(stats);
            },
          ),
          const SizedBox(height: 24),
          _buildMascotBanner(),
          const SizedBox(height: 24),
          if (topInsight != null) ...[
             _buildInsightPreviewCard(context, topInsight),
             const SizedBox(height: 24),
          ],
          _buildMenuGrid(context),
          const SizedBox(height: 24),
          _buildDailyQuests(),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayerStats stats) {
     final double xpProgress = (stats.requiredXp == 0) ? 0 : (stats.xp / stats.requiredXp);
    return Card(
      elevation: 8,
      shadowColor: AppColors.secondaryAccent.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text( 'Petualang Keuangan', style: TextStyle( fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            Text( 'Level ${stats.level}', style: const TextStyle( fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Text( 'XP: ${stats.xp} / ${stats.requiredXp}', style: const TextStyle( color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // --- KEMBALIKAN PARAMETER tween & builder ---
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: xpProgress),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.accentLime),
                  ),
                );
              },
            ),
             // --- BATAS PERBAIKAN ---
          ],
        ),
      ),
    );
  }


  Widget _buildMascotBanner() {
     return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.primaryAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3))),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, size: 40, color: AppColors.primaryAccent),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sistem Lencana AKTIF!', style: TextStyle( fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                Text('Selesaikan tantangan untuk membuka lencana kehormatan!', style: TextStyle(color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightPreviewCard(BuildContext context, Insight insight) {
    return Card(
      margin: EdgeInsets.zero,
      color: insight.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: insight.color.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InsightsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: insight.color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(insight.iconData, color: insight.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( insight.title, style: TextStyle( fontWeight: FontWeight.bold, color: insight.color)),
                     Text( insight.message, style: const TextStyle(color: AppColors.textLight, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuCard( context, title: 'Daftar Misi', icon: Icons.list_alt_rounded, color: AppColors.accentLime, onTap: () { Navigator.push( context, MaterialPageRoute(builder: (context) => ExpenseListScreen()),);},),
        _buildMenuCard( context, title: 'Kategori', icon: Icons.category_rounded, color: AppColors.primaryAccent, onTap: () { Navigator.push( context, MaterialPageRoute(builder: (context) => const CategoryScreen()),);},),
        _buildMenuCard( context, title: 'Insight', icon: Icons.insights_rounded, color: AppColors.accentFieryOrange, onTap: () { Navigator.push( context, MaterialPageRoute(builder: (context) => const InsightsScreen()),);},),
        _buildMenuCard( context, title: 'Lencana', icon: Icons.emoji_events_rounded, color: Colors.yellow.shade700, onTap: () { Navigator.push( context, MaterialPageRoute(builder: (context) => const AchievementsScreen()),);},),
        _buildMenuCard( context, title: 'Pengaturan', icon: Icons.settings_rounded, color: AppColors.secondaryAccent, onTap: () { Navigator.push( context, MaterialPageRoute( builder: (context) => const SettingsScreen()),);},),
      ],
    );
  }

   Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
     // --- KEMBALIKAN PARAMETER child ---
     return HoverScaleCard(
       onTap: onTap,
       borderRadius: BorderRadius.circular(16),
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(16),
         side: BorderSide(color: color.withOpacity(0.3), width: 1),
       ),
       child: Container( // Ini adalah child-nya
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: color.withOpacity(0.15),
           borderRadius: BorderRadius.circular(16),
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                   color: color,
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)
                   ]),
               child: Icon(icon, size: 32, color: Colors.black),
             ),
             const SizedBox(height: 8),
             Text(
               title,
               textAlign: TextAlign.center,
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.bold,
                 color: color,
               ),
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
             ),
           ],
         ),
       ),
     );
     // --- BATAS PERBAIKAN ---
   }


  Widget _buildDailyQuests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text( 'Misi Harian', style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        _buildQuestItem( title: 'Mencatat 1 pengeluaran', description: '+10 XP', isCompleted: true),
        _buildQuestItem( title: 'Hemat! (di bawah Rp 50.000)', description: '+50 XP, +10 Koin', isCompleted: false),
        _buildQuestItem( title: 'Login 3 hari berturut-turut', description: '+100 XP', isCompleted: false),
      ],
    );
  }

  // --- KEMBALIKAN PARAMETER ---
  Widget _buildQuestItem({
    required String title,
    required String description,
    required bool isCompleted,
  }) {
     return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: isCompleted ? AppColors.accentLime : AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(
                  color:
                      isCompleted ? AppColors.accentLime : AppColors.textLight)),
          child: Icon( isCompleted ? Icons.check_rounded : Icons.hourglass_empty_rounded, color: isCompleted ? Colors.black : AppColors.textLight),
        ),
        title: Text( title, style: TextStyle( fontWeight: FontWeight.bold, color: isCompleted ? AppColors.textLight : AppColors.textDark, decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none)),
        subtitle: Text( description, style: TextStyle( color: isCompleted ? AppColors.accentLime : AppColors.textLight, fontWeight: FontWeight.w600)),
      ),
    );
  }
  // --- BATAS PERBAIKAN ---


   void _showLogoutDialog(BuildContext context) {
     // --- KEMBALIKAN PARAMETER context & builder ---
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.sentiment_dissatisfied_outlined, color: AppColors.accentFieryOrange, size: 28),
              const SizedBox(width: 10),
              const Text('Yakin ingin keluar?'),
            ],
          ),
          content: const Text('Petualanganmu akan dijeda sampai kamu kembali lagi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textLight)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil( context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              },
              style: ElevatedButton.styleFrom( backgroundColor: AppColors.accentFieryOrange, foregroundColor: AppColors.textDark),
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
      // --- BATAS PERBAIKAN ---
   }
}