// lib/utils/looping_examples.dart

import '../models/expense.dart';
import '../services/category_service.dart'; // Impor service

class LoopingExamples {
  // 1. Menghitung total dengan berbagai cara
  
  // Cara 1: For loop tradisional
  static double calculateTotalTraditional(List<Expense> expenses) {
    double total = 0;
    for (int i = 0; i < expenses.length; i++) {
      total += expenses[i].amount;
    }
    return total;
  }

  // Cara 2: For-in loop
  static double calculateTotalForIn(List<Expense> expenses) {
    double total = 0;
    for (Expense expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // Cara 3: forEach method
  static double calculateTotalForEach(List<Expense> expenses) {
    double total = 0;
    expenses.forEach((expense) {
      total += expense.amount;
    });
    return total;
  }

  // Cara 4: fold method (paling efisien)
  static double calculateTotalFold(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount); // Perbaikan 0.0
  }

  // Cara 5: reduce method
  static double calculateTotalReduce(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    return expenses.map((e) => e.amount).reduce((a, b) => a + b);
  }

  // 2. Mencari item dengan berbagai cara
  
  // Cara 1: For loop dengan break
  static Expense? findExpenseTraditional(List<Expense> expenses, String id) {
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].id == id) {
        return expenses[i];
      }
    }
    return null;
  }

  // Cara 2: firstWhere method
  static Expense? findExpenseWhere(List<Expense> expenses, String id) {
    try {
      return expenses.firstWhere((expense) => expense.id == id); // Akan error jika tidak ditemukan, jadi pakai try-catch
    } catch (e) {
      return null;
    }
  }

  // 3. Filtering dengan berbagai cara
  
  // Cara 1: Loop manual dengan List.add()
  static List<Expense> filterByCategoryManual(List<Expense> expenses, String categoryName) {
    List<Expense> result = [];
    for (Expense expense in expenses) {
      // Ambil nama kategori dari service
      final catName = categoryService.getCategoryById(expense.categoryId).name;
      if (catName.toLowerCase() == categoryName.toLowerCase()) {
        result.add(expense);
      }
    }
    return result;
  }

  // Cara 2: where method (lebih efisien)
  static List<Expense> filterByCategoryWhere(List<Expense> expenses, String categoryName) {
    return expenses.where((expense) {
      final catName = categoryService.getCategoryById(expense.categoryId).name;
      return catName.toLowerCase() == categoryName.toLowerCase();
    }).toList();
  }
}