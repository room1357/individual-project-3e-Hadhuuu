// lib/models/expense.dart

import 'package:hive/hive.dart';

// 1. Tambahkan baris "part" ini
part 'expense.g.dart';

// 2. Tambahkan anotasi @HiveType
@HiveType(typeId: 0)
class Expense {
  // 3. Tambahkan anotasi @HiveField untuk setiap properti
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final String categoryId;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.description,
  });
}