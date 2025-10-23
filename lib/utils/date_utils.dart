// lib/utils/date_utils.dart

import 'package:intl/intl.dart';

class DateUtils {
  // 'intl' juga dipakai di sini
  static String formatFullDate(DateTime date, {String locale = 'id_ID'}) {
    final format = DateFormat.yMMMMd(locale); // misal: 23 Oktober 2025
    return format.format(date);
  }

  static String formatSimpleDate(DateTime date, {String locale = 'id_ID'}) {
    final format = DateFormat('dd/MM/yy'); // misal: 23/10/25
    return format.format(date);
  }
}