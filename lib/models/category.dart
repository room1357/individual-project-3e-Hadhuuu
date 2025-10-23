// lib/models/category.dart

import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int xpReward; // <-- PROPERTI BARU

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.xpReward, // <-- TAMBAHKAN DI CONSTRUCTOR
  });
}