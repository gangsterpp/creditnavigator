import 'dart:math';

import 'package:creditnavigator/domain/loan.dart';
import 'package:creditnavigator/domain/payments_type.dart';

abstract class LoanCalculator {
  /// Рассчитывает фиксированный аннуитетный платеж.
  double calculateAnnuityPayment(Loan loan);

  /// Рассчитывает список дифференцированных платежей по месяцам.
  List<double> calculateDifferentiatedPayments(Loan loan);
}

/// Реализация калькулятора платежей.
class LoanCalculatorImpl implements LoanCalculator {
  @override
  double calculateAnnuityPayment(Loan loan) {
    final double monthlyRate = loan.annualInterestRate / 12 / 100;
    final double powValue = pow(1 + monthlyRate, loan.termInMonths).toDouble();
    // Формула аннуитетного платежа:
    // A = P * (i * (1 + i)^n) / ((1 + i)^n - 1)
    return loan.principal * monthlyRate * powValue / (powValue - 1);
  }

  @override
  List<double> calculateDifferentiatedPayments(Loan loan) {
    final double monthlyRate = loan.annualInterestRate / 12 / 100;
    final double monthlyPrincipal = loan.principal / loan.termInMonths;
    List<double> payments = [];
    for (int month = 0; month < loan.termInMonths; month++) {
      double remainingPrincipal = loan.principal - monthlyPrincipal * month;
      double interest = remainingPrincipal * monthlyRate;
      payments.add(monthlyPrincipal + interest);
    }
    return payments;
  }
}

sealed class PaymentCalculationResult {
  final double totalPayment;
  final double interestOverpayment;

  const PaymentCalculationResult({
    required this.totalPayment,
    required this.interestOverpayment,
  });
}

/// Результат расчёта для аннуитетного платежа.
class AnnuityPaymentResult extends PaymentCalculationResult {
  final double monthlyPayment;
  AnnuityPaymentResult({
    required this.monthlyPayment,
    required super.totalPayment,
    required super.interestOverpayment,
  });
}

/// Результат расчёта для дифференцированного платежа.
class DifferentiatedPaymentResult extends PaymentCalculationResult {
  final List<double> monthlyPayments;
  DifferentiatedPaymentResult({
    required this.monthlyPayments,
    required super.totalPayment,
    required super.interestOverpayment,
  });
}

/// Функция для расчёта платежей.
/// Она возвращает результат расчёта в виде объекта [PaymentCalculationResult].
PaymentCalculationResult calculateLoanResults({
  required Loan loan,
  required PaymentsType paymentType,
  required LoanCalculator calculator,
}) {
  // Валидация входных параметров
  if (loan.principal <= 0) {
    throw ArgumentError("Сумма кредита должна быть больше 0.");
  }
  if (loan.termInMonths <= 0) {
    throw ArgumentError("Срок кредита должен быть больше 0 месяцев.");
  }
  if (loan.annualInterestRate < 0) {
    throw ArgumentError("Процентная ставка не может быть отрицательной.");
  }

  // Аннуитетный платеж
  if (paymentType is AnnuityPayment) {
    final monthlyPayment = calculator.calculateAnnuityPayment(loan);
    final totalPayment = monthlyPayment * loan.termInMonths;
    final interestOverpayment = totalPayment - loan.principal;
    return AnnuityPaymentResult(
      monthlyPayment: monthlyPayment,
      totalPayment: totalPayment,
      interestOverpayment: interestOverpayment,
    );
  }
  // Дифференцированный платеж
  final monthlyPayments = calculator.calculateDifferentiatedPayments(loan);
  final totalPayment = monthlyPayments.fold(0.0, (sum, payment) => sum + payment);
  final interestOverpayment = totalPayment - loan.principal;
  return DifferentiatedPaymentResult(
    monthlyPayments: monthlyPayments,
    totalPayment: totalPayment,
    interestOverpayment: interestOverpayment,
  );
}
