// lib/screens/category_screen.dart

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
// Hapus 'app_theme.dart' jika tidak dipakai
import '../widgets/hover_scale_card.dart'; // Impor kartu interaktif kita

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Kategori Misi'),
      ),
      body: ValueListenableBuilder<List<Category>>(
        valueListenable: categoryService.categories,
        builder: (context, categories, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1, // Buat kartu sedikit lebih tinggi
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          );
        },
      ),
      // Nanti bisa ditambahkan FAB untuk menambah kategori baru
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return HoverScaleCard(
      onTap: () {
        // Nanti ini bisa diarahkan ke halaman
        // daftar expense yang sudah difilter berdasarkan kategori
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ini adalah kategori ${category.name}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            ),
            backgroundColor: category.color,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: category.color.withOpacity(0.3), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: category.color.withOpacity(0.5),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Icon(category.icon, size: 36, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: category.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}