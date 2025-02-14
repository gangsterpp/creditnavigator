import 'dart:convert';

import 'package:creditnavigator/domain/history_data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesRepository {
  Future<void> saveAnnuityPayment(double payment);
  Future<List<String>> loadAnnuityPayment();

  Future<void> saveDifferentiatedPayments(List<double> payments);
  Future<List<String>> loadDifferentiatedPayments();
  Future<List<HistoryData>> loadAll();
}

class PreferencesRepositoryImpl implements PreferencesRepository {
  final SharedPreferences sharedPreferences;

  const PreferencesRepositoryImpl(this.sharedPreferences);

  @override
  Future<void> saveAnnuityPayment(double payment) async {
    final array = await loadAnnuityPayment();
    final json = {
      'annuityPayment': payment,
      'date': DateFormat('dd MMMM yyyy hh:mm:ss', 'ru_RU').format(DateTime.now()),
    };
    array.add(jsonEncode(json));
    await sharedPreferences.setString('annuity_payment', array.join(';'));
  }

  @override
  Future<List<String>> loadAnnuityPayment() async {
    final str = sharedPreferences.getString('annuity_payment');
    if (str == null) return [];
    return str.split(';');
  }

  @override
  Future<void> saveDifferentiatedPayments(List<double> payments) async {
    final array = await loadDifferentiatedPayments();
    final json = {
      'differentiated_payments': payments.map((e) => e.toStringAsFixed(2)).join(','),
      'date': DateFormat('dd MMMM yyyy hh:mm:ss', 'ru_RU').format(DateTime.now()),
    };
    array.add(jsonEncode(json));
    await sharedPreferences.setString('differentiated_payments', array.join(';'));
  }

  @override
  Future<List<String>> loadDifferentiatedPayments() async {
    final stringPayments = sharedPreferences.getString('differentiated_payments');
    if (stringPayments == null) return [];
    return stringPayments.split(';');
  }

  @override
  Future<List<HistoryData>> loadAll() async {
    try {
      final dif = await loadDifferentiatedPayments();
      final diffData = dif.map((e) => HistoryData.loadDifferentiatedPayments(e)).toList();

      final annu = await loadAnnuityPayment();
      final annuData = annu.map((e) => HistoryData.loadAnnuityPayment(e)).toList();
      final all = [...diffData, ...annuData];
      all.sort((f, s) {
        return s.date.compareTo(f.date);
      });
      return all;
    } catch (e) {
      rethrow;
    }
  }
}
