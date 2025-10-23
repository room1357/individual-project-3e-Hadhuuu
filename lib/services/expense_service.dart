// lib/services/expense_service.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';
import 'category_service.dart';
import 'game_service.dart';
import 'achievement_service.dart';

class ExpenseService {
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  late final ValueNotifier<List<Expense>> _expenses;

  ExpenseService() {
    // Tetap cek jika box kosong, isi HANYA jika benar-benar kosong
    if (_expenseBox.isEmpty) {
      _expenseBox.addAll(_createVariedSampleData()); // Gunakan data baru
    }
    _expenses = ValueNotifier<List<Expense>>(_expenseBox.values.toList());
  }

  ValueNotifier<List<Expense>> get expenses => _expenses;

  void _refreshNotifier() {
    _expenses.value = _expenseBox.values.toList();
  }

  void addExpense(Expense expense) {
    _expenseBox.put(expense.id, expense);
    _refreshNotifier();
    try {
      final category = categoryService.getCategoryById(expense.categoryId);
      gameService.addExperience(category.xpReward);
    } catch (e) { print('Gagal memberi XP: $e'); }
    achievementService.checkAchievements();
  }

  void updateExpense(Expense updatedExpense) {
    _expenseBox.put(updatedExpense.id, updatedExpense);
    _refreshNotifier();
  }

  void deleteExpense(String id) {
    _expenseBox.delete(id);
    _refreshNotifier();
    achievementService.checkAchievements(); // Cek lagi jika ada ach. count
  }

  Expense? getExpenseById(String id) {
    return _expenseBox.get(id);
  }

  // --- FUNGSI BARU UNTUK MEMBUAT DATA SAMPEL YANG VARIATIF ---
  List<Expense> _createVariedSampleData() {
    final now = DateTime.now();
    final List<Expense> data = [];
    int idCounter = 1;

    // Helper untuk membuat expense
    Expense createSample(String title, double amount, String catId, int daysAgo, [String desc = '']) {
      return Expense(
        id: 'sample_$idCounter', // ID unik
        title: title,
        amount: amount,
        categoryId: catId,
        date: now.subtract(Duration(days: daysAgo)),
        description: desc.isEmpty ? title : desc,
      );
    }

    // --- MINGGU INI (daysAgo: 0-6) ---
    data.add(createSample('Kopi Pagi', 25000, 'c1', 0));
    data.add(createSample('Makan Siang Kantor', 35000, 'c1', 1));
    data.add(createSample('Bensin Motor', 50000, 'c2', 1));
    data.add(createSample('Top Up Game', 150000, 'c4', 2, 'Promo skin baru'));
    data.add(createSample('Nonton Bioskop', 100000, 'c4', 3));
    data.add(createSample('Belanja Sayur', 75000, 'c1', 4));
    data.add(createSample('Ojek Online', 15000, 'c2', 5));
    idCounter++; // Increment ID counter

    // --- MINGGU LALU (daysAgo: 7-13) ---
    // Buat minggu lalu agak boros di Hiburan
    data.add(createSample('Konser Musik', 500000, 'c4', 7, 'Tiket festival')); // Pengeluaran besar
    data.add(createSample('Makan Malam Spesial', 250000, 'c1', 8));
    data.add(createSample('Langganan Streaming', 50000, 'c4', 9));
    data.add(createSample('Transportasi Kereta', 80000, 'c2', 10));
    data.add(createSample('Beli Buku', 120000, 'c5', 11));
    data.add(createSample('Cemilan Malam', 40000, 'c1', 12));
    idCounter++;

    // --- 2 MINGGU LALU (daysAgo: 14-20) ---
    // Buat minggu ini normal
    data.add(createSample('Bayar Listrik', 280000, 'c3', 14));
    data.add(createSample('Bayar Internet', 320000, 'c3', 15));
    data.add(createSample('Isi Bensin Mobil', 200000, 'c2', 16));
    data.add(createSample('Periksa Dokter', 150000, 'c6', 17));
    data.add(createSample('Traktir Teman', 100000, 'c1', 18));
    data.add(createSample('Alat Tulis Kantor', 60000, 'c7', 19));
    idCounter++;

    // --- 3 MINGGU LALU (daysAgo: 21-27) ---
    // Buat minggu ini hemat
    data.add(createSample('Masak di Rumah', 50000, 'c1', 21, 'Bahan makanan mingguan'));
    data.add(createSample('Naik Angkot', 10000, 'c2', 22));
    data.add(createSample('Fotokopi Dokumen', 5000, 'c7', 23));
    data.add(createSample('Obat Flu', 30000, 'c6', 25));
    idCounter++;

    // Tambahkan beberapa lagi agar data lebih banyak
     data.add(createSample('Donasi', 50000, 'c7', 30));
     data.add(createSample('Servis Motor', 180000, 'c2', 35));

    return data;
  }
  // --- BATAS FUNGSI DATA SAMPEL ---
}

final expenseService = ExpenseService();