// lib/services/insight_service.dart

import 'package:collection/collection.dart'; // Impor untuk groupBy
import '../models/expense.dart';
import '../models/insight.dart';
import '../services/expense_service.dart';
import '../services/category_service.dart';
import '../utils/currency_utils.dart';

class InsightService {
  // Ambil data expenses dari service utama
  List<Expense> get _expenses => expenseService.expenses.value;

  // --- FUNGSI UTAMA UNTUK MENGHASILKAN INSIGHTS ---
  List<Insight> generateInsights() {
    final List<Insight> insights = [];
    if (_expenses.length < 5) {
      // Belum cukup data untuk analisis berarti
      return [Insight.info('Mulai Mencatat!', 'Catat lebih banyak misimu untuk mendapatkan analisis mendalam.')];
    }

    // 1. Analisis Tren Mingguan
    final weeklyTotals = calculateWeeklySpending(4); // Analisis 4 minggu terakhir
    _addWeeklyTrendInsights(weeklyTotals, insights);

    // 2. Analisis Perbandingan Kategori (Minggu ini vs Minggu Lalu)
    final categoryComparison = compareCategorySpending();
    _addCategoryComparisonInsights(categoryComparison, insights);

    // 3. Analisis Kategori Teratas Minggu Ini
    _addTopSpendingCategoryInsight(categoryComparison.thisWeekTotals, insights);

    // 4. (Opsional) Deteksi Anomali (Pengeluaran Besar Tiba-tiba)
    _addAnomalyInsights(_expenses, insights);

    // Urutkan insight: Warning dulu, baru Good, baru Info
    insights.sort((a, b) {
      if (a.type == InsightType.warning && b.type != InsightType.warning) return -1;
      if (b.type == InsightType.warning && a.type != InsightType.warning) return 1;
      if (a.type == InsightType.good && b.type == InsightType.info) return -1;
      if (b.type == InsightType.good && a.type == InsightType.info) return 1;
      return 0;
    });

    return insights;
  }

  // --- HELPER UNTUK KALKULASI ---

  // Menghitung total pengeluaran per minggu (0=minggu ini, 1=minggu lalu, dst)
  Map<int, double> calculateWeeklySpending(int numberOfWeeks) {
    final now = DateTime.now();
    // Tentukan hari pertama minggu ini (misal: Senin)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    Map<int, double> weeklyTotals = Map.fromIterable(
      List.generate(numberOfWeeks, (i) => i),
      key: (i) => i,
      value: (i) => 0.0,
    );

    for (var expense in _expenses) {
      // Hitung berapa minggu lalu expense ini terjadi
      final expenseDateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
      final weeksAgo = (today.difference(expenseDateOnly).inDays / 7).floor();

      if (weeksAgo >= 0 && weeksAgo < numberOfWeeks) {
        weeklyTotals[weeksAgo] = (weeklyTotals[weeksAgo] ?? 0) + expense.amount;
      }
    }
    return weeklyTotals;
  }

  // Membandingkan total pengeluaran per kategori minggu ini vs minggu lalu
  ({Map<String, double> thisWeekTotals, Map<String, double> lastWeekTotals}) compareCategorySpending() {
     final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final startOfLastWeek = today.subtract(const Duration(days: 7));

    Map<String, double> thisWeekTotals = {};
    Map<String, double> lastWeekTotals = {};

    for (var expense in _expenses) {
       final expenseDateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
      
      // Cek apakah di minggu ini
      if (!expenseDateOnly.isBefore(today)) {
         thisWeekTotals[expense.categoryId] = (thisWeekTotals[expense.categoryId] ?? 0) + expense.amount;
      } 
      // Cek apakah di minggu lalu
      else if (!expenseDateOnly.isBefore(startOfLastWeek)) {
        lastWeekTotals[expense.categoryId] = (lastWeekTotals[expense.categoryId] ?? 0) + expense.amount;
      }
    }
    return (thisWeekTotals: thisWeekTotals, lastWeekTotals: lastWeekTotals);
  }

  // --- HELPER UNTUK MENAMBAHKAN INSIGHTS ---

  void _addWeeklyTrendInsights(Map<int, double> weeklyTotals, List<Insight> insights) {
    final thisWeekTotal = weeklyTotals[0] ?? 0.0;
    final lastWeekTotal = weeklyTotals[1] ?? 0.0;
    final twoWeeksAgoTotal = weeklyTotals[2] ?? 0.0;

    if (thisWeekTotal > lastWeekTotal * 1.3 && lastWeekTotal > 0) { // Naik > 30%
      insights.add(Insight.warning(
        'Tren Naik Signifikan!',
        'Total pengeluaranmu minggu ini (${CurrencyUtils.formatCurrency(thisWeekTotal)}) jauh lebih tinggi dari minggu lalu (${CurrencyUtils.formatCurrency(lastWeekTotal)}). Waspada!',
      ));
    } else if (thisWeekTotal < lastWeekTotal * 0.7 && thisWeekTotal > 0) { // Turun > 30%
       insights.add(Insight.good(
        'Hemat Minggu Ini!',
        'Kerja bagus! Pengeluaranmu minggu ini (${CurrencyUtils.formatCurrency(thisWeekTotal)}) turun drastis dibanding minggu lalu (${CurrencyUtils.formatCurrency(lastWeekTotal)}).',
      ));
    } else if (thisWeekTotal > lastWeekTotal && lastWeekTotal > 0) {
       insights.add(Insight.info(
        'Pengeluaran Sedikit Naik',
        'Minggu ini (${CurrencyUtils.formatCurrency(thisWeekTotal)}) kamu belanja sedikit lebih banyak dari minggu lalu (${CurrencyUtils.formatCurrency(lastWeekTotal)}).',
      ));
    }

    // Cek tren 3 minggu
    if (thisWeekTotal > lastWeekTotal && lastWeekTotal > twoWeeksAgoTotal && twoWeeksAgoTotal > 0) {
       insights.add(Insight.warning(
        'Tren Naik Beruntun!',
        'Hati-hati, pengeluaranmu terus naik selama 3 minggu terakhir. Mungkin ada yang perlu dievaluasi?',
      ));
    }
  }

  void _addCategoryComparisonInsights(({Map<String, double> thisWeekTotals, Map<String, double> lastWeekTotals}) categoryComparison, List<Insight> insights) {
     final thisWeek = categoryComparison.thisWeekTotals;
     final lastWeek = categoryComparison.lastWeekTotals;
     final allCategoryIds = {...thisWeek.keys, ...lastWeek.keys}; // Gabungkan semua ID kategori yang ada

     String? biggestIncreaseCatName;
     double biggestIncreaseAmount = 0;

     String? biggestDecreaseCatName;
     double biggestDecreaseAmount = 0;


     for (var catId in allCategoryIds) {
       final thisWeekAmount = thisWeek[catId] ?? 0.0;
       final lastWeekAmount = lastWeek[catId] ?? 0.0;
       final difference = thisWeekAmount - lastWeekAmount;
       final category = categoryService.getCategoryById(catId);

       if (difference > 0 && lastWeekAmount > 0) { // Ada kenaikan
          final percentageIncrease = (difference / lastWeekAmount) * 100;
          if (percentageIncrease > 50) { // Kenaikan > 50%
             insights.add(Insight.warning(
              'Lonjakan di ${category.name}!',
              'Pengeluaran ${category.name} melonjak ${percentageIncrease.toStringAsFixed(0)}% minggu ini. Ada apa?',
            ));
          }
          if (difference > biggestIncreaseAmount) {
             biggestIncreaseAmount = difference;
             biggestIncreaseCatName = category.name;
          }
       } else if (difference < 0) { // Ada penurunan
           final percentageDecrease = (difference.abs() / lastWeekAmount) * 100;
            if (percentageDecrease > 50) { // Penurunan > 50%
             insights.add(Insight.good(
              'Penghematan di ${category.name}!',
              'Mantap! Pengeluaran ${category.name} berhasil ditekan ${percentageDecrease.toStringAsFixed(0)}% minggu ini.',
            ));
          }
           if (difference.abs() > biggestDecreaseAmount) {
             biggestDecreaseAmount = difference.abs();
             biggestDecreaseCatName = category.name;
          }
       }
     }
     // Tambahkan info kenaikan/penurunan terbesar jika ada
      if (biggestIncreaseCatName != null) {
        insights.add(Insight.info(
          'Kenaikan Terbesar',
          '$biggestIncreaseCatName naik ${CurrencyUtils.formatCurrency(biggestIncreaseAmount)} minggu ini.',
        ));
      }
       if (biggestDecreaseCatName != null) {
        insights.add(Insight.info(
          'Penurunan Terbesar',
          '$biggestDecreaseCatName turun ${CurrencyUtils.formatCurrency(biggestDecreaseAmount)} minggu ini.',
        ));
      }
  }

  void _addTopSpendingCategoryInsight(Map<String, double> thisWeekTotals, List<Insight> insights) {
    if (thisWeekTotals.isEmpty) return;
    
    // Cari kategori dengan pengeluaran tertinggi minggu ini
    final topCategoryEntry = thisWeekTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    final topCategory = categoryService.getCategoryById(topCategoryEntry.key);
    final topAmount = topCategoryEntry.value;

    insights.add(Insight.info(
      'Spotlight Minggu Ini',
      'Pengeluaran terbesarmu minggu ini ada di kategori ${topCategory.name} (${CurrencyUtils.formatCurrency(topAmount)}).',
    ));
  }

  void _addAnomalyInsights(List<Expense> expenses, List<Insight> insights) {
      // Cari pengeluaran terbesar dalam 7 hari terakhir
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final recentExpenses = expenses.where((e) => e.date.isAfter(oneWeekAgo)).toList();
      
      if (recentExpenses.length < 3) return; // Butuh beberapa data untuk deteksi

      // Urutkan berdasarkan amount
      recentExpenses.sort((a,b) => b.amount.compareTo(a.amount));
      final largestExpense = recentExpenses.first;
      
      // Hitung rata-rata pengeluaran (selain yg terbesar)
      double averageAmount = 0;
      if (recentExpenses.length > 1) {
          averageAmount = recentExpenses.skip(1).fold(0.0, (sum, e) => sum + e.amount) / (recentExpenses.length - 1);
      }

      // Jika pengeluaran terbesar > 5x rata-rata, anggap anomali
      if (largestExpense.amount > averageAmount * 5 && averageAmount > 0) {
          final category = categoryService.getCategoryById(largestExpense.categoryId);
          insights.add(Insight.warning(
            'Anomali Terdeteksi!',
            'Ada pengeluaran ${category.name} (${CurrencyUtils.formatCurrency(largestExpense.amount)}) yang jauh lebih besar dari rata-rata (${CurrencyUtils.formatCurrency(averageAmount)}) minggu ini. Apakah ini benar?',
          ));
      }
  }
}

// Buat instance global (Singleton)
final insightService = InsightService();