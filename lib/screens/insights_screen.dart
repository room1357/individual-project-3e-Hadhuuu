// lib/screens/insights_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart'; // <-- IMPOR INI
import '../models/insight.dart';
import '../services/insight_service.dart';
import '../services/category_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = insightService.generateInsights();
    final weeklyData = insightService.calculateWeeklySpending(4);
    final categoryComparison = insightService.compareCategorySpending();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Oracle's Insight"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildChartCard(
            title: 'Tren Mingguan',
            icon: Icons.show_chart_rounded,
            chart: _buildWeeklyTrendChart(weeklyData),
          ),
          const SizedBox(height: 24),
          _buildChartCard(
            title: 'Kategori: Minggu Ini vs Lalu',
            icon: Icons.compare_arrows_rounded,
            chart: _buildCategoryComparisonChart(categoryComparison),
          ),
          const SizedBox(height: 24),
          if (insights.isNotEmpty) ...[
            _buildSectionTitle('Ramalan Oracle', Icons.auto_awesome_outlined),
            ...insights.map((insight) => _buildInsightCard(insight)).toList(),
          ] else
            const Center(child: Text("Oracle belum punya ramalan untukmu.")),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required IconData icon, required Widget chart}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryAccent),
                const SizedBox(width: 8),
                Text( title, style: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox( height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
     return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryAccent),
          const SizedBox(width: 8),
          Text( title, style: const TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Insight insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: insight.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: insight.color.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: Icon(insight.iconData, color: insight.color, size: 28),
        title: Text( insight.title, style: TextStyle( fontWeight: FontWeight.bold, color: insight.color)),
        subtitle: Text( insight.message, style: const TextStyle(color: AppColors.textLight)),
      ),
    );
  }

  Widget _buildWeeklyTrendChart(Map<int, double> weeklyData) {
    double maxY = 0.0;
    if (weeklyData.values.isNotEmpty) {
      maxY = weeklyData.values.reduce((a, b) => a > b ? a : b);
    }
    if (maxY == 0) maxY = 100000;

    final spots = weeklyData.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
        ..sort((a, b) => b.x.compareTo(a.x));

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 4,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine( color: AppColors.primaryAccent.withOpacity(0.1), strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine( color: AppColors.primaryAccent.withOpacity(0.1), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                String text;
                switch (value.toInt()) {
                  case 0: text = 'Minggu Ini'; break;
                  case 1: text = 'Minggu Lalu'; break;
                  case 2: text = '2 Mgg Lalu'; break;
                  case 3: text = '3 Mgg Lalu'; break;
                  default: return Container();
                }
                return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: const TextStyle(color: AppColors.textLight, fontSize: 10)));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient( colors: [AppColors.primaryAccent, AppColors.secondaryAccent]),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [ AppColors.primaryAccent.withOpacity(0.3), AppColors.secondaryAccent.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
         lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.card,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final weekDesc = ['Minggu Ini', 'Minggu Lalu', '2 Mgg Lalu', '3 Mgg Lalu'];
                return LineTooltipItem(
                  '${weekDesc[spot.x.toInt()]}\n',
                  const TextStyle(color: AppColors.textLight, fontSize: 12),
                  children: [
                     TextSpan( text: CurrencyUtils.formatCurrency(spot.y), style: const TextStyle( color: AppColors.primaryAccent, fontWeight: FontWeight.bold)),
                  ]
                );
              }).toList();
            }
          )
        ),
      ),
    );
  }

  Widget _buildCategoryComparisonChart(({Map<String, double> thisWeekTotals, Map<String, double> lastWeekTotals}) categoryComparison) {
     final thisWeek = categoryComparison.thisWeekTotals;
     final lastWeek = categoryComparison.lastWeekTotals;
     final allCategoryIds = {...thisWeek.keys, ...lastWeek.keys}.toList();

      double maxY = 0.0;
      for (var catId in allCategoryIds) {
        if ((thisWeek[catId] ?? 0.0) > maxY) maxY = thisWeek[catId]!;
        if ((lastWeek[catId] ?? 0.0) > maxY) maxY = lastWeek[catId]!;
      }
      if (maxY == 0) maxY = 100000;

      // --- PERBAIKAN: GUNAKAN .mapIndexed DARI collection ---
      final barGroups = allCategoryIds.mapIndexed((index, catId) {
      // --- BATAS PERBAIKAN ---
        final category = categoryService.getCategoryById(catId);
        return BarChartGroupData(
          x: index,
          barsSpace: 4,
          barRods: [
            BarChartRodData( toY: lastWeek[catId] ?? 0.0, color: AppColors.secondaryAccent.withOpacity(0.5), width: 10, borderRadius: BorderRadius.zero),
            BarChartRodData( toY: thisWeek[catId] ?? 0.0, color: AppColors.primaryAccent, width: 10, borderRadius: BorderRadius.zero),
          ]
        );
      }).toList();

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barGroups: barGroups,
        titlesData: FlTitlesData(
           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           bottomTitles: AxisTitles(
             sideTitles: SideTitles(
               showTitles: true,
               reservedSize: 40,
               getTitlesWidget: (value, meta) {
                 final index = value.toInt();
                 if (index >= 0 && index < allCategoryIds.length) {
                   final category = categoryService.getCategoryById(allCategoryIds[index]);
                   return SideTitleWidget( axisSide: meta.axisSide, space: 4, child: Icon(category.icon, color: AppColors.textLight, size: 18));
                 }
                 return Container();
               }
             )
           )
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine( color: AppColors.primaryAccent.withOpacity(0.1), strokeWidth: 1),
        ),
         borderData: FlBorderData(show: false),
         barTouchData: BarTouchData(
           touchTooltipData: BarTouchTooltipData(
             getTooltipColor: (barGroup) => AppColors.card,
             getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 final category = categoryService.getCategoryById(allCategoryIds[group.x]);
                 final period = rodIndex == 0 ? 'Minggu Lalu' : 'Minggu Ini';
                 final amount = CurrencyUtils.formatCurrency(rod.toY);
                 return BarTooltipItem(
                   '${category.name}\n',
                   const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12),
                   children: [
                      TextSpan( text: '$period: $amount', style: TextStyle( color: rodIndex == 0 ? AppColors.secondaryAccent : AppColors.primaryAccent, fontSize: 11)),
                   ]
                 );
             }
           )
         )
      ),
    );
  }
}