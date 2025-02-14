import 'dart:convert';

import 'package:intl/intl.dart';

class HistoryData {
  final DateTime date;
  final double? annuityPayment;
  final List<String>? differentiatedPayments;
  const HistoryData({
    required this.annuityPayment,
    required this.date,
    required this.differentiatedPayments,
  });

  factory HistoryData.loadAnnuityPayment(String data) {
    final json = jsonDecode(data);
    return HistoryData(
      annuityPayment: json['annuityPayment'],
      date: DateFormat('dd MMMM yyyy hh:mm:ss', 'ru_RU').parse(json['date']),
      differentiatedPayments: null,
    );
  }
  factory HistoryData.loadDifferentiatedPayments(String data) {
    final json = jsonDecode(data);
    return HistoryData(
      annuityPayment: null,
      date: DateFormat('dd MMMM yyyy hh:mm:ss', 'ru_RU').parse(json['date']),
      differentiatedPayments: (json['differentiated_payments'] as String).split(','),
    );
  }
}
