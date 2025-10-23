// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'about_screen.dart'; // Impor AboutScreen
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Game'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            context,
            icon: Icons.person_rounded,
            title: 'Akun Pemain',
            subtitle: 'Atur detail profil dan password',
            onTap: () {},
          ),
          _buildSettingsCard(
            context,
            icon: Icons.notifications_rounded,
            title: 'Notifikasi Misi',
            subtitle: 'Atur pengingat harian',
            onTap: () {},
          ),
          _buildSettingsCard(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Tentang Game',
            subtitle: 'Lihat info developer',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: AppColors.primaryAccent, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 18, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}