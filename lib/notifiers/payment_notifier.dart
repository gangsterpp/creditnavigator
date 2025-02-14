import 'package:creditnavigator/domain/loan.dart';
import 'package:creditnavigator/domain/loan_calculator.dart';
import 'package:creditnavigator/domain/payments_type.dart';
import 'package:creditnavigator/domain/preferences_repository.dart';
import 'package:flutter/material.dart';

/// ChangeNotifier для управления состоянием расчёта платежей.
class PaymentNotifier extends ChangeNotifier {
  @protected
  final LoanCalculator calculator;
  @protected
  final PreferencesRepository preferencesRepository;

  double? _annuityPayment;

  /// Результат для аннуитетного типа
  double? get annuityPayment => _annuityPayment;

  /// Результаты для дифференцированного типа
  final differentiatedPayments = <double>[];

  String? _errorMessage;

  /// Сообщение об ошибке, если расчет не прошёл.
  String? get errorMessage => _errorMessage;

  PaymentCalculationResult? _loadResult;

  /// Результат последнего расчета
  PaymentCalculationResult? get loadResult => _loadResult;

  PaymentNotifier({required this.calculator, required this.preferencesRepository});

  /// Пересчитывает платежи в зависимости от выбранного типа.
  Future<void> calculatePayments(Loan loan, PaymentsType paymentType) async {
    try {
      // Сбрасываем предыдущее сообщение об ошибке
      _errorMessage = null;
      _annuityPayment = null;
      differentiatedPayments.clear();

      // Валидация входных параметров
      if (loan.principal <= 0) {
        _errorMessage = "Сумма кредита должна быть больше 0.";
        return;
      }
      if (loan.termInMonths <= 0) {
        _errorMessage = "Срок кредита должен быть больше 0 месяцев.";
        return;
      }
      if (loan.annualInterestRate < 0) {
        _errorMessage = "Процентная ставка не может быть отрицательной.";
        return;
      }

      // Расчёт в зависимости от выбранного типа платежа
      if (paymentType is AnnuityPayment) {
        _annuityPayment = calculator.calculateAnnuityPayment(loan);
        if (annuityPayment == null) return;
        await preferencesRepository.saveAnnuityPayment(annuityPayment!);
      } else {
        differentiatedPayments
          ..clear()
          ..addAll(calculator.calculateDifferentiatedPayments(loan));
        await preferencesRepository.saveDifferentiatedPayments(differentiatedPayments);
      }
      _loadResult = calculateLoanResults(loan: loan, paymentType: paymentType, calculator: calculator);
    } catch (e) {
      _errorMessage = '$e';
      _annuityPayment = null;
      differentiatedPayments.clear();
    } finally {
      notifyListeners();
    }
  }
}
