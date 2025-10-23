// lib/main.dart

import 'dart:async'; // <-- 1. Impor async untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/expense.dart';
import 'models/player_stats.dart';
import 'models/achievement.dart'; // <-- 2. Impor model Achievement
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/achievement_service.dart'; // <-- 3. Impor Achievement Service
import 'widgets/achievement_unlocked_dialog.dart'; // <-- 4. Impor Dialog Notifikasi (akan dibuat)

// --- 5. Global StreamSubscription ---
StreamSubscription<Achievement>? achievementSubscription;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // --- INISIALISASI HIVE ---
  await Hive.initFlutter();

  // Daftarkan SEMUA adapter
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(PlayerStatsAdapter());
  Hive.registerAdapter(AchievementAdapter()); // <-- 6. Daftarkan adapter baru

  // Buka SEMUA kotak
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<PlayerStats>('playerStats');
  // Kotak untuk menyimpan ID achievement yg sudah terbuka
  await Hive.openBox<String>('unlockedAchievements'); // <-- 7. Buka kotak baru

  // --- 8. Inisialisasi Service Achievement ---
  // Kita panggil ini agar service langsung load data saat app start
  achievementService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget { // <-- 9. Ubah jadi StatefulWidget
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> { // <-- 10. Buat State

  // --- 11. Tambahkan Listener Notifikasi ---
  @override
  void initState() {
    super.initState();
    // Dengarkan stream dari achievement service
    achievementSubscription = achievementService.newlyUnlockedAchievementStream.listen(
      (achievement) {
        // Tampilkan dialog saat ada achievement baru
        // Kita butuh GlobalKey untuk akses Navigator dari luar build context
        _showAchievementUnlockedDialog(achievement);
      }
    );
  }

  @override
  void dispose() {
    // Hentikan listener saat app ditutup
    achievementSubscription?.cancel();
    super.dispose();
  }

  // GlobalKey untuk Navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void _showAchievementUnlockedDialog(Achievement achievement) {
    // Pastikan ada context navigator
    if (navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AchievementUnlockedDialog(achievement: achievement),
      );
    }
  }
  // --- Batas Listener Notifikasi ---


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // <-- 12. Pasang GlobalKey
      title: 'Petualangan Finansial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],
      
      home: const LoginScreen(),
    );
  }
}