// lib/services/storage_service.dart

import 'dart:io'; // Untuk File
import 'package:csv/csv.dart'; // Impor package CSV
import 'package:path_provider/path_provider.dart'; // Impor package Path
import 'package:open_file_plus/open_file_plus.dart'; // Impor package OpenFile
import 'package:permission_handler/permission_handler.dart'; // Impor package Permission
import '../models/expense.dart';
import 'category_service.dart';
import '../utils/date_utils.dart';

class StorageService {
  // Fungsi utama untuk export CSV
  Future<bool> exportToCSV(List<Expense> expenses) async {
    try {
      // 1. Minta Izin
      if (!(await _requestPermission())) {
        print('Izin penyimpanan ditolak.');
        return false;
      }

      // 2. Siapkan Data
      List<List<dynamic>> csvData = [
        // Header
        [
          'ID',
          'Judul Misi',
          'Jumlah (Rp)',
          'Kategori',
          'Tanggal',
          'Deskripsi'
        ],
        // Data Rows
        ...expenses.map((expense) {
          final category = categoryService.getCategoryById(expense.categoryId);
          return [
            expense.id,
            expense.title,
            expense.amount,
            category.name,
            DateUtils.formatSimpleDate(expense.date),
            expense.description,
          ];
        }),
      ];

      // 3. Ubah data menjadi String CSV
      String csvString = const ListToCsvConverter().convert(csvData);

      // 4. Tentukan lokasi & nama file
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/laporan_misi_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);

      // 5. Tulis file
      await file.writeAsString(csvString);

      // 6. Buka file
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        print('Gagal membuka file: ${result.message}');
        return false;
      }

      return true;
    } catch (e) {
      print('Error saat export CSV: $e');
      return false;
    }
  }

  // Helper untuk meminta izin
  Future<bool> _requestPermission() async {
    // Di Android modern, kita tidak butuh izin khusus untuk
    // menulis ke getApplicationDocumentsDirectory().
    // Tapi untuk 'storage' (jika ingin simpan di Download), kita butuh.
    // Kita cek izin 'storage' untuk berjaga-jaga.
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // Minta izin
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return true;
  }

  // "Quest Lanjutan: Export Data" (PDF)
  Future<void> exportToPDF(List<Expense> expenses) async {
    print('LOGIKA EXPORT PDF AKAN DIIMPLEMENTASIKAN DI SINI');
    // Ini butuh package 'pdf' dan 'printing'
  }
}

// Buat satu instance global (Singleton)
final storageService = StorageService();