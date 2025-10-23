// lib/utils/currency_utils.dart

import 'package:intl/intl.dart';

class CurrencyUtils {
  // Kita butuh package 'intl' untuk ini.
  // Tambahkan 'intl: ^0.18.0' (atau versi terbaru) ke pubspec.yaml Anda
  static String formatCurrency(double amount, {String locale = 'id_ID'}) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: 'Rp ', // Simbol Rupiah
      decimalDigits: 0, // Tidak pakai desimal
    );
    return format.format(amount);
  }
}

// Catatan: Setelah menambah 'intl', jalankan 'flutter pub get'