import 'dart:math';

import 'package:creditnavigator/domain/loan.dart';
import 'package:creditnavigator/domain/loan_calculator.dart';
import 'package:creditnavigator/domain/payments_type.dart';
import 'package:test/test.dart';

void main() {
  group('LoanCalculator', () {
    final calculator = LoanCalculatorImpl();

    test('throws error when principal is <= 0', () {
      final loan = Loan(principal: 0, termInMonths: 12, annualInterestRate: 12);
      expect(
        () => calculateLoanResults(
          loan: loan,
          paymentType: AnnuityPayment(),
          calculator: calculator,
        ),
        throwsArgumentError,
      );
    });

    test('throws error when termInMonths is <= 0', () {
      final loan = Loan(principal: 100000, termInMonths: 0, annualInterestRate: 12);
      expect(
        () => calculateLoanResults(
          loan: loan,
          paymentType: AnnuityPayment(),
          calculator: calculator,
        ),
        throwsArgumentError,
      );
    });

    test('throws error when annualInterestRate is negative', () {
      final loan = Loan(principal: 100000, termInMonths: 12, annualInterestRate: -5);
      expect(
        () => calculateLoanResults(
          loan: loan,
          paymentType: AnnuityPayment(),
          calculator: calculator,
        ),
        throwsArgumentError,
      );
    });

    test('calculates annuity payment correctly', () {
      // Пример: кредит 100 000, срок 12 месяцев, ставка 12%
      final loan = Loan(principal: 100000, termInMonths: 12, annualInterestRate: 12);
      final result = calculateLoanResults(
        loan: loan,
        paymentType: AnnuityPayment(),
        calculator: calculator,
      );
      expect(result, isA<AnnuityPaymentResult>());
      final annuityResult = result as AnnuityPaymentResult;

      // Расчет ожидаемого ежемесячного платежа по формуле:
      // A = P * (i * (1 + i)^n) / ((1 + i)^n - 1)
      final double monthlyRate = 12 / 12 / 100; // 0.01
      final double powValue = pow(1 + monthlyRate, 12).toDouble();
      final double expectedMonthlyPayment = 100000 * monthlyRate * powValue / (powValue - 1);
      final double expectedTotalPayment = expectedMonthlyPayment * 12;
      final double expectedInterestOverpayment = expectedTotalPayment - 100000;

      expect(annuityResult.monthlyPayment, closeTo(expectedMonthlyPayment, 0.001));
      expect(annuityResult.totalPayment, closeTo(expectedTotalPayment, 0.001));
      expect(annuityResult.interestOverpayment, closeTo(expectedInterestOverpayment, 0.001));
    });

    test('calculates differentiated payments correctly', () {
      // Пример: кредит 100 000, срок 12 месяцев, ставка 12%
      final loan = Loan(principal: 100000, termInMonths: 12, annualInterestRate: 12);
      final result = calculateLoanResults(
        loan: loan,
        paymentType: DifferentiatedPayment(),
        calculator: calculator,
      );
      expect(result, isA<DifferentiatedPaymentResult>());
      final diffResult = result as DifferentiatedPaymentResult;

      // Проверяем, что список платежей содержит 12 значений
      expect(diffResult.monthlyPayments.length, equals(12));

      // Сумма всех платежей должна быть равна totalPayment
      final totalPayment = diffResult.monthlyPayments.reduce((a, b) => a + b);
      expect(diffResult.totalPayment, closeTo(totalPayment, 0.001));

      // Переплата по процентам = totalPayment - principal
      expect(diffResult.interestOverpayment, closeTo(totalPayment - 100000, 0.001));
    });
  });
}
