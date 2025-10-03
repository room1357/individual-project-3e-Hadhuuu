import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/models/expense_manager.dart';
import 'package:pemrograman_mobile/screens/advanced_expense_list_screen.dart';
import 'package:pemrograman_mobile/screens/profile_screen.dart';
import 'login_screen.dart';
import 'expense_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data terpusat dari ExpenseManager
    final allExpenses = ExpenseManager.expenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard('Pengeluaran', Icons.attach_money, Colors.green, () {
                    // UBAH: Kirim data ke ExpenseListScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseListScreen(expenses: allExpenses), // Kirim data
                      ),
                    );
                  }),
                  _buildDashboardCard('Profil', Icons.person, Colors.blue, () {
                    // UBAH: Arahkan ke ProfileScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  }),
                  // TAMBAHKAN: Menu baru untuk Laporan Advanced
                  _buildDashboardCard('Laporan Advanced', Icons.analytics, Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdvancedExpenseListScreen(expenses: allExpenses), // Kirim data
                      ),
                    );
                  }),
                  _buildDashboardCard('Pengaturan', Icons.settings, Colors.purple, null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color, VoidCallback? onTap) {
    return Card(
      elevation: 4,
      child: Builder(
        builder: (context) => InkWell(
          onTap: onTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur $title segera hadir!')),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}