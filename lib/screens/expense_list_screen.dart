// lib/screens/expense_list_screen.dart

import 'package:flutter/material.dart' hide DateUtils; // <-- PERUBAHAN DI SINI
import '../models/category.dart';
import '../models/expense.dart';
import '../services/category_service.dart';
import '../services/expense_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart'; // Impor baru
import '../utils/date_utils.dart'; // Impor baru
import 'add_expense_screen.dart'; // Impor baru
import 'edit_expense_screen.dart'; // Impor baru

class ExpenseListScreen extends StatelessWidget {
  ExpenseListScreen({super.key});

  // HAPUS data hardcoded, karena sudah pindah ke service
  // final List<Expense> expenses_data = [ ... ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Misi Selesai'),
      ),
      // Gunakan ValueListenableBuilder untuk "mendengar" perubahan data
      body: ValueListenableBuilder<List<Expense>>(
        valueListenable: expenseService.expenses,
        builder: (context, expenses, child) {
          // Urutkan list berdasarkan tanggal terbaru
          expenses.sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              _buildTotalHeader(expenses), // Kirim data yang didapat ke header
              
              // Tampilkan pesan jika list kosong
              if (expenses.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 80, color: AppColors.textLight),
                        SizedBox(height: 16),
                        Text('Belum ada misi dilaporkan!',
                          style: TextStyle(fontSize: 18, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Tampilkan list jika ada data
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      // Ambil detail kategori dari category service
                      final category =
                          categoryService.getCategoryById(expense.categoryId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          hoverColor: AppColors.primaryAccent.withOpacity(0.1),
                          splashColor: AppColors.primaryAccent.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          subtitle: Text(
                            // Gunakan util format tanggal
                            '${category.name} • ${DateUtils.formatSimpleDate(expense.date)}',
                            style: const TextStyle(color: AppColors.textLight),
                          ),
                          trailing: Text(
                            // Gunakan util format mata uang
                            CurrencyUtils.formatCurrency(expense.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.accentFieryOrange,
                            ),
                          ),
                          onTap: () {
                            // Navigasi ke Edit Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditExpenseScreen(expense: expense),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke Add Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
        },
        label: const Text('Misi Baru'),
        icon: const Icon(Icons.add_rounded, size: 24),
      ),
    );
  }

  // Header Total yang cantik
  Widget _buildTotalHeader(List<Expense> expenses) {
    // Hitung total dari list yang diterima
    final total = expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryAccent.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total "Damage" Misi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            CurrencyUtils.formatCurrency(total), // Gunakan util
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}