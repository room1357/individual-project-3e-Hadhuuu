// lib/screens/advanced_expense_list_screen.dart

import 'package:flutter/material.dart' hide DateUtils; // Perbaikan konflik
import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_service.dart'; // Impor service
import '../services/category_service.dart'; // Impor service
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart'; // Impor util
import '../utils/date_utils.dart'; // Impor util
import 'edit_expense_screen.dart'; // Impor layar edit

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState
    extends State<AdvancedExpenseListScreen> {
  
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'semua'; // Ubah ke ID 'semua'
  TextEditingController searchController = TextEditingController();
  
  // Variabel untuk menampung data asli dari service
  List<Expense> _allExpenses = [];

  @override
  void initState() {
    super.initState();
    // Ambil data awal dari service
    _allExpenses = expenseService.expenses.value;
    filteredExpenses = _allExpenses;
    // Dengarkan perubahan pada service
    expenseService.expenses.addListener(_onExpensesChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    // Hentikan listener
    expenseService.expenses.removeListener(_onExpensesChanged);
    super.dispose();
  }
  
  // Fungsi untuk update UI jika data di service berubah
  void _onExpensesChanged() {
    setState(() {
      _allExpenses = expenseService.expenses.value;
      _filterExpenses(); // Terapkan filter lagi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papan Skor Keuangan'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari misi...',
                prefixIcon: const Icon(Icons.search_rounded),
                prefixIconColor: AppColors.primaryAccent,
              ),
              onChanged: (value) {
                _filterExpenses();
              },
            ),
          ),

          // Category filter
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Ambil kategori dari service
              children: [
                _buildCategoryChip('Semua', 'semua'),
                ...categoryService.categories.value.map((cat) {
                  return _buildCategoryChip(cat.name, cat.id);
                }).toList(),
              ],
            ),
          ),

          // Statistics summary
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Skor', _calculateTotal(filteredExpenses)),
                _buildStatCard('Total Misi', '${filteredExpenses.length}'),
                _buildStatCard(
                    'Rata-rata', _calculateAverage(filteredExpenses)),
              ],
            ),
          ),

          // Expense list
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 80, color: AppColors.textLight),
                      SizedBox(height: 16),
                      Text('Tidak ada misi ditemukan!',
                          style: TextStyle(
                              fontSize: 18, color: AppColors.textLight)),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      // Ambil kategori dari service
                      final category = categoryService.getCategoryById(expense.categoryId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: category.color,
                            child: Icon(
                              category.icon,
                              color: Colors.black,
                            ),
                          ),
                          title: Text(expense.title),
                          subtitle: Text(
                              // Gunakan util
                              '${category.name} • ${DateUtils.formatSimpleDate(expense.date)}'),
                          trailing: Text(
                            // Gunakan util
                            CurrencyUtils.formatCurrency(expense.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  // Widget untuk Chip Kategori
  Widget _buildCategoryChip(String label, String categoryId) {
    bool isSelected = selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primaryAccent,
        checkmarkColor: Colors.black,
        onSelected: (selected) {
          setState(() {
            selectedCategory = categoryId;
            _filterExpenses();
          });
        },
      ),
    );
  }

  void _filterExpenses() {
    setState(() {
      // Mulai dari data lengkap
      filteredExpenses = _allExpenses.where((expense) {
        // Ambil nama kategori untuk pencarian
        final categoryName = categoryService.getCategoryById(expense.categoryId).name;

        bool matchesSearch = searchController.text.isEmpty ||
            expense.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            expense.description
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            categoryName // Cari berdasarkan nama kategori juga
                .toLowerCase()
                .contains(searchController.text.toLowerCase());

        bool matchesCategory = selectedCategory == 'semua' ||
            expense.categoryId == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Papan Skor
  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Gunakan util
  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return CurrencyUtils.formatCurrency(total);
  }

  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return CurrencyUtils.formatCurrency(0);
    double average =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount) /
            expenses.length;
    return CurrencyUtils.formatCurrency(average);
  }
}