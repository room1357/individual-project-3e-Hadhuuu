# Petualangan Finansial: Aplikasi Expense Manager Gamified 🎮💰

Aplikasi mobile Flutter untuk mencatat pengeluaran harian dengan pendekatan gamifikasi yang seru. Pengguna adalah "Petualang Keuangan" yang bisa naik level, mendapatkan XP, dan mengumpulkan lencana dengan mencatat "misi" (pengeluaran) mereka.

## ✨ Fitur Utama

* **Pencatatan Misi (CRUD):** Tambah, lihat, edit, dan hapus data pengeluaran dengan mudah.
* **Sistem Level & XP:** Dapatkan Experience Points (XP) setiap mencatat pengeluaran berdasarkan kategori, dan naikkan level Petualangmu!
* **Hall of Glory (Achievements):** Buka berbagai macam lencana kehormatan berdasarkan pencapaian finansial (misal: mencapai level tertentu, mencatat N misi, dll). Notifikasi pop-up keren saat lencana baru terbuka!
* **Oracle's Insight (Statistik & Analisis):**
    * Visualisasi tren pengeluaran mingguan (Line Chart).
    * Perbandingan pengeluaran per kategori minggu ini vs. minggu lalu (Bar Chart).
    * Kartu insight otomatis yang memberikan peringatan atau tips berdasarkan pola pengeluaran.
* **Manajemen Kategori:** Lihat daftar kategori misi yang tersedia.
* **Penyimpanan Permanen:** Semua data misi, level, XP, dan lencana tersimpan lokal di device menggunakan Hive.
* **Export Data:** Ekspor seluruh riwayat misi ke dalam format file CSV.
* **Tema Neon Magic:** Tampilan Dark Mode yang keren dengan aksen warna neon yang "menyala".
* **UI Interaktif:** Efek hover dan animasi sentuh pada kartu dan grafik.

## 🚀 Getting Started / Cara Menjalankan

1.  Pastikan Flutter SDK sudah terinstal di komputermu.
2.  Clone repository ini: `git clone <URL_REPOSITORY_ANDA>`
3.  Masuk ke direktori proyek: `cd nama-folder-proyek`
4.  Install dependencies: `flutter pub get`
5.  Jalankan code generator untuk Hive (jika ada perubahan model): `flutter pub run build_runner build --delete-conflicting-outputs`
6.  Jalankan aplikasi di emulator atau device: `flutter run`

## 🛠️ Teknologi yang Digunakan

* **Framework:** Flutter
* **Bahasa:** Dart
* **Database Lokal:** Hive
* **Grafik:** fl_chart
* **Format Data:** intl
* **File Handling:** csv, path_provider, open_file_plus
* **Permissions:** permission_handler
* **Code Generation:** hive_generator, build_runner

## 📝 To-Do / Rencana Pengembangan (Opsional)

* Kustomisasi Maskot.
* Sinkronisasi Cloud (opsional).

---

Made with ❤️ and 🎮