// lib/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- Impor FL Chart
import '../models/category.dart';
import '../models/expense.dart';
import '../services/category_service.dart';
import '../services/expense_service.dart';
import '../services/storage_service.dart'; // Impor Storage Service
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';

// --- DIUBAH MENJADI STATEFULWIDGET ---
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Variabel untuk menyimpan state "sentuhan" pada pie chart
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Petualangan'),
        actions: [
          // Tombol Export
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primaryAccent),
            onPressed: () => _showExportDialog(context), // Panggil fungsi export
            tooltip: 'Export Laporan',
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Expense>>(
        valueListenable: expenseService.expenses,
        builder: (context, expenses, child) {
          // Proses data
          final totalSpending =
              expenses.fold(0.0, (sum, item) => sum + item.amount);
          
          // Data untuk Pie Chart & Legend
          final Map<String, double> categoryTotals = _getCategoryTotals(expenses);
          // Urutkan data untuk legend
          final sortedCategoryTotals = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          final pieData = _preparePieChartData(categoryTotals, totalSpending);
          final barData = _prepareBarChartData(expenses);

          if (expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_moon_rounded,
                      size: 80, color: AppColors.textLight),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data misi untuk ditampilkan',
                    style: TextStyle(color: AppColors.textLight, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Kartu Total
              _buildTotalStatCard(totalSpending),
              const SizedBox(height: 24),

              // 2. Pie Chart (Dibungkus Card)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sebaran "Damage"',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // --- PERBAIKAN DI SINI: LAYOUT BARU DENGAN LEGEND ---
                      Row(
                        children: [
                          // Bagian Kiri: Pie Chart
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 250, // Ukuran chart
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection == null) {
                                          _touchedPieIndex = -1;
                                          return;
                                        }
                                        _touchedPieIndex = pieTouchResponse
                                            .touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  sections: pieData,
                                  centerSpaceRadius: 50,
                                  sectionsSpace: 4,
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Bagian Kanan: Legend
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sortedCategoryTotals.map((entry) {
                                final category = categoryService.getCategoryById(entry.key);
                                final percentage = (entry.value / totalSpending) * 100;
                                return _buildLegendItem(
                                  category.color,
                                  category.name,
                                  '${percentage.toStringAsFixed(1)}%',
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      // --- BATAS PERBAIKAN ---
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Bar Chart (Dibungkus Card)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aktivitas 7 Hari',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          _buildBarChartConfig(barData),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HELPER UNTUK MEMPROSES DATA GRAFIK ---

  // Helper baru untuk data pie
  Map<String, double> _getCategoryTotals(List<Expense> expenses) {
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  // 1. Memproses data untuk Pie Chart
  List<PieChartSectionData> _preparePieChartData(Map<String, double> categoryTotals, double totalSpending) {
    
    if (totalSpending == 0) return [];

    // Ubah menjadi PieChartSectionData
    int i = 0;
    return categoryTotals.entries.map((entry) {
      final category = categoryService.getCategoryById(entry.key);

      // Cek apakah ini bagian yang disentuh
      final isTouched = (i == _touchedPieIndex);
      final radius = isTouched ? 70.0 : 60.0; // Radius lebih kecil
      final elevation = isTouched ? 8.0 : 4.0;

      i++; // increment index

      return PieChartSectionData(
        color: category.color,
        value: entry.value,
        // --- PERBAIKAN: HILANGKAN TULISAN PERSEN DI CHART ---
        title: '', 
        // title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        badgeWidget: isTouched ? 
          Chip(
            label: Text(category.name, style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
            backgroundColor: category.color.withOpacity(0.8),
            padding: EdgeInsets.zero,
          ) : null,
        badgePositionPercentageOffset: 1.4,
        // --- BATAS PERBAIKAN ---
      );
    }).toList();
  }
  
  // Widget baru untuk item legend
  Widget _buildLegendItem(Color color, String name, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                 Text(
                  percentage,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Memproses data untuk Bar Chart
  Map<int, double> _prepareBarChartData(List<Expense> expenses) {
    Map<int, double> dailyTotals = {
      0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0,
    };
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var expense in expenses) {
      final difference = today.difference(expense.date).inDays;
      if (difference >= 0 && difference < 7) {
        dailyTotals[difference] = (dailyTotals[difference] ?? 0) + expense.amount;
      }
    }
    return dailyTotals;
  }
  
  // Gradasi untuk Bar Chart
  final _barGradient = LinearGradient(
    colors: [
      AppColors.primaryAccent,
      AppColors.primaryAccent.withOpacity(0.1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 3. Konfigurasi Bar Chart
  BarChartData _buildBarChartConfig(Map<int, double> dailyTotals) {
    double maxY = 0.0;
    if (dailyTotals.values.isNotEmpty) {
      maxY = dailyTotals.values.reduce((a, b) => a > b ? a : b);
    }
    // Pastikan maxY tidak 0, agar grafik tidak error
    if (maxY == 0) maxY = 1; 

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY * 1.2, // Atur Y maks
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (barGroup) => AppColors.card,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final day = _getWeekdayLabel(group.x.toInt());
            final amount = CurrencyUtils.formatCurrency(rod.toY);
            return BarTooltipItem(
              '$day\n',
              const TextStyle(color: AppColors.textLight, fontSize: 12),
              children: [
                TextSpan(
                  text: amount,
                  style: const TextStyle(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4,
                child: Text(
                  _getWeekdayLabel(value.toInt()),
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 10,
                  ),
                ),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.primaryAccent.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      barGroups: dailyTotals.entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key, // 0-6 (hari)
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  gradient: _barGradient,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          )
          .toList()
          .reversed // Balik agar "Hari ini" (0) ada di paling kanan
          .toList(),
    );
  }

  // Helper untuk label hari
  String _getWeekdayLabel(int dayDifference) {
    if (dayDifference == 0) return 'Hari Ini';
    if (dayDifference == 1) return 'Kemarin';
    final weekday = DateTime.now().subtract(Duration(days: dayDifference)).weekday;
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return labels[weekday - 1];
  }

  // Helper untuk kartu total
  Widget _buildTotalStatCard(double total) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient, // Gradasi Lime
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              'Total "Damage" Sejauh Ini',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Text(
              CurrencyUtils.formatCurrency(total),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI UNTUK EXPORT ---
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: AppColors.primaryAccent),
            SizedBox(width: 10),
            Text('Export Laporan'),
          ],
        ),
        content: const Text(
            'Kamu akan men-generate laporan misi dalam format CSV. File ini bisa dibuka di Excel atau Google Sheets. Lanjutkan?'),
        actions: [
          TextButton(
            child: const Text('Batal', style: TextStyle(color: AppColors.textLight)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
            ),
            child: const Text('Export Sekarang'),
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              _doExport(context); // Lakukan export
            },
          ),
        ],
      ),
    );
  }

  // Fungsi yang memanggil service
  void _doExport(BuildContext context) async {
    // Tampilkan SnackBar "Loading"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mempersiapkan laporan...',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColors.accentLime,
      ),
    );

    // Ambil data terbaru
    final expenses = expenseService.expenses.value;
    final success = await storageService.exportToCSV(expenses);

    // Tutup SnackBar "Loading"
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Tampilkan hasil
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Laporan berhasil dibuat dan dibuka!',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: AppColors.accentLime,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal membuat laporan. Cek izin aplikasi.',
            style: TextStyle(color: AppColors.textDark),
          ),
          backgroundColor: AppColors.accentFieryOrange,
        ),
      );
    }
  }
}