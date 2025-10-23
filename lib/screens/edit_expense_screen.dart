// lib/screens/edit_expense_screen.dart

import 'package:flutter/material.dart' hide DateUtils;
import '../models/category.dart';
import '../models/expense.dart';
import '../services/category_service.dart';
import '../services/expense_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
// Hapus import '../widgets/category_selector_dialog.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  late Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _descController = TextEditingController(text: widget.expense.description);
    _selectedDate = widget.expense.date;
    _selectedCategory =
        categoryService.getCategoryById(widget.expense.categoryId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate ?? _selectedDate;
    });
  }

  // HAPUS fungsi _selectCategory()

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Tidak perlu validasi kategori terpisah

      final title = _titleController.text;
      final amount = double.tryParse(_amountController.text) ?? 0;
      final description = _descController.text;

      final updatedExpense = Expense(
        id: widget.expense.id,
        title: title,
        amount: amount,
        categoryId: _selectedCategory!.id,
        date: _selectedDate,
        description: description,
      );

      expenseService.updateExpense(updatedExpense);
      Navigator.pop(context);
    }
  }

  void _deleteExpense() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.accentFieryOrange),
            const SizedBox(width: 10),
            const Text('Hapus Misi?'),
          ],
        ),
        content: const Text(
            'Apakah kamu yakin ingin menghapus laporan misi ini? Aksi ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            child: const Text('Batal', style: TextStyle(color: AppColors.textLight)),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentFieryOrange,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Hapus'),
            onPressed: () {
              expenseService.deleteExpense(widget.expense.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar kategori dari service (diperlukan lagi)
    final categories = categoryService.categories.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Laporan Misi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded,
                color: AppColors.accentFieryOrange),
            onPressed: _deleteExpense,
            tooltip: 'Hapus Misi',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul Misi
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: const InputDecoration(
                  labelText: 'Judul Misi',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul misi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jumlah "Damage" (Amount)
              TextFormField(
                controller: _amountController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: const InputDecoration(
                  labelText: 'Jumlah "Damage"',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null ||
                      double.tryParse(value)! <= 0) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tanggal
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal Misi: ${DateUtils.formatFullDate(_selectedDate)}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.primaryAccent),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- KEMBALIKAN KE DropdownButtonFormField ---
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 12),
                        Text(category.name, style: const TextStyle(color: AppColors.textDark)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Pilih Tipe Misi',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                dropdownColor: AppColors.card,
                validator: (value) {
                  if (value == null) {
                    return 'Kategori harus dipilih';
                  }
                  return null;
                },
              ),
              // --- BATAS PENGEMBALIAN ---
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: Colors.black,
                    shadowColor: AppColors.accentLime.withOpacity(0.5)),
                child: const Text('SIMPAN PERUBAHAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}