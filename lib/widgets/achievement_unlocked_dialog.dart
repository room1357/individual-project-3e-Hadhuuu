// lib/widgets/achievement_unlocked_dialog.dart

import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';

class AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementUnlockedDialog({super.key, required this.achievement});

  @override
  State<AchievementUnlockedDialog> createState() => _AchievementUnlockedDialogState();
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward(); // Mulai animasi saat dialog muncul
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16), // Padding bawah lebih kecil
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Judul "Achievement Unlocked!"
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_rounded, color: AppColors.accentLime, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Lencana Terbuka!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentLime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lencana Besar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: achievement.color.withOpacity(0.2),
                  border: Border.all(color: achievement.color, width: 3),
                  boxShadow: [
                     BoxShadow(color: achievement.color.withOpacity(0.5), blurRadius: 15)
                  ]
                ),
                child: Icon(
                  achievement.iconData,
                  size: 60,
                  color: achievement.color,
                ),
              ),
              const SizedBox(height: 16),

              // Nama Lencana
              Text(
                achievement.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Deskripsi Lencana
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol OK
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Keren!',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}