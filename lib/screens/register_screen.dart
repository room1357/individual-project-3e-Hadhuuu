// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Tombol back akan otomatis muncul
        title: const Text('Buat Akun Baru'),
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bergabunglah dengan Guild!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mulai petualangan finansialmu hari ini.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 48),

              // Field email
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  prefixIconColor: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 16),

              // Field username
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  prefixIconColor: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 16),

              // Field password
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  prefixIconColor: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 32),

              // Tombol register
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text(
                    'DAFTAR DAN MASUK',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Link kembali ke login
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Kembali ke LoginScreen
                },
                child: const Text(
                  'Sudah punya akun? Masuk',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
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