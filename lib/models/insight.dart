// lib/models/insight.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // Impor warna tema

// Tipe Insight: Peringatan, Informasi, atau Kabar Baik
enum InsightType { warning, info, good }

class Insight {
  final InsightType type;
  final String title;
  final String message;
  final IconData iconData;
  final Color color;

  Insight({
    required this.type,
    required this.title,
    required this.message,
    required this.iconData,
    required this.color,
  });

  // Factory constructor untuk membuat insight berdasarkan tipe
  factory Insight.warning(String title, String message) {
    return Insight(
      type: InsightType.warning,
      title: title,
      message: message,
      iconData: Icons.warning_amber_rounded,
      color: AppColors.accentFieryOrange,
    );
  }

  factory Insight.info(String title, String message) {
    return Insight(
      type: InsightType.info,
      title: title,
      message: message,
      iconData: Icons.info_outline_rounded,
      color: AppColors.primaryAccent, // Cyan
    );
  }

  factory Insight.good(String title, String message) {
    return Insight(
      type: InsightType.good,
      title: title,
      message: message,
      iconData: Icons.check_circle_outline_rounded,
      color: AppColors.accentLime, // Lime
    );
  }
}