// lib/services/category_service.dart

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart'; // Impor warna neon kita

class CategoryService {
  // Gunakan ValueNotifier agar UI bisa "mendengar" perubahan
  final ValueNotifier<List<Category>> _categories =
      ValueNotifier<List<Category>>(_defaultCategories);
  
  // Getter publik untuk didengarkan oleh UI
  ValueNotifier<List<Category>> get categories => _categories;

  // Fungsi untuk mendapatkan satu kategori berdasarkan ID
  Category getCategoryById(String id) {
    try {
      return _categories.value.firstWhere((c) => c.id == id);
    } catch (e) {
      // Jika tidak ketemu, kembalikan kategori 'default'
      return _defaultCategories.last; 
    }
  }
}

// Buat satu instance global (Singleton) agar bisa diakses dari mana saja
final categoryService = CategoryService();

// --- UPDATE DAFTAR KATEGORI DENGAN XP REWARD ---
final List<Category> _defaultCategories = [
  Category(
    id: 'c1',
    name: 'Makanan & Minuman',
    icon: Icons.fastfood_rounded,
    color: Colors.orange.shade300,
    xpReward: 10, // Misi mudah
  ),
  Category(
    id: 'c2',
    name: 'Transportasi',
    icon: Icons.directions_car_rounded,
    color: Colors.green.shade300,
    xpReward: 15, // Sedang
  ),
  Category(
    id: 'c3',
    name: 'Tagihan & Utilitas',
    icon: Icons.home_rounded,
    color: Colors.purple.shade300,
    xpReward: 30, // Misi bulanan, XP besar
  ),
  Category(
    id: 'c4',
    name: 'Hiburan & Game',
    icon: Icons.sports_esports_rounded,
    color: AppColors.secondaryAccent, // Orchid
    xpReward: 20, // Menyenangkan!
  ),
  Category(
    id: 'c5',
    name: 'Pendidikan',
    icon: Icons.school_rounded,
    color: Colors.blue.shade300,
    xpReward: 25,
  ),
  Category(
    id: 'c6',
    name: 'Kesehatan',
    icon: Icons.health_and_safety_rounded,
    color: Colors.red.shade300,
    xpReward: 20,
  ),
  Category(
    id: 'c7',
    name: 'Lainnya',
    icon: Icons.inventory_2_rounded,
    color: AppColors.textLight,
    xpReward: 5, // Default
  ),
];