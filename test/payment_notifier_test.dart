import 'package:creditnavigator/domain/history_data.dart';
import 'package:creditnavigator/domain/loan.dart';
import 'package:creditnavigator/domain/loan_calculator.dart';
import 'package:creditnavigator/domain/payments_type.dart';
import 'package:creditnavigator/domain/preferences_repository.dart';
import 'package:creditnavigator/notifiers/payment_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

// Фейковая реализация LoanCalculator для тестирования.
class FakeLoanCalculator implements LoanCalculator {
  @override
  double calculateAnnuityPayment(Loan loan) {
    // Для теста возвращаем фиксированное значение
    return 1000.0;
  }

  @override
  List<double> calculateDifferentiatedPayments(Loan loan) {
    // Возвращаем список платежей, равных 900.0 для каждого месяца
    return List.generate(loan.termInMonths, (_) => 900.0);
  }
}

class FakePreferencesRepository implements PreferencesRepository {
  double? savedAnnuity;
  List<double>? savedDifferentiated;

  @override
  Future<void> saveAnnuityPayment(double payment) async {
    savedAnnuity = payment;
  }

  @override
  Future<List<String>> loadAnnuityPayment() async {
    return savedAnnuity != null ? [savedAnnuity.toString()] : [];
  }

  @override
  Future<void> saveDifferentiatedPayments(List<double> payments) async {
    savedDifferentiated = payments;
  }

  @override
  Future<List<String>> loadDifferentiatedPayments() async {
    return savedDifferentiated?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  Future<List<HistoryData>> loadAll() async {
    return [];
  }
}

void main() {
  group('PaymentNotifier', () {
    late FakeLoanCalculator fakeCalculator;
    late FakePreferencesRepository fakePreferences;
    late PaymentNotifier notifier;

    setUp(() {
      fakeCalculator = FakeLoanCalculator();
      fakePreferences = FakePreferencesRepository();
      notifier = PaymentNotifier(
        calculator: fakeCalculator,
        preferencesRepository: fakePreferences,
      );
    });

    test('should set error when principal is <= 0', () async {
      final loan = Loan(principal: 0, termInMonths: 12, annualInterestRate: 12);
      await notifier.calculatePayments(loan, AnnuityPayment());
      expect(notifier.errorMessage, "Сумма кредита должна быть больше 0.");
    });

    test('should set error when termInMonths is <= 0', () async {
      final loan = Loan(principal: 100000, termInMonths: 0, annualInterestRate: 12);
      await notifier.calculatePayments(loan, AnnuityPayment());
      expect(notifier.errorMessage, "Срок кредита должен быть больше 0 месяцев.");
    });

    test('should set error when annualInterestRate is negative', () async {
      final loan = Loan(principal: 100000, termInMonths: 12, annualInterestRate: -5);
      await notifier.calculatePayments(loan, AnnuityPayment());
      expect(notifier.errorMessage, "Процентная ставка не может быть отрицательной.");
    });

    test('should calculate annuity payment correctly', () async {
      final loan = Loan(principal: 100000, termInMonths: 12, annualInterestRate: 12);
      await notifier.calculatePayments(loan, AnnuityPayment());
      // FakeCalculator возвращает 1000.0
      expect(notifier.annuityPayment, 1000.0);
      expect(notifier.loadResult, isA<AnnuityPaymentResult>());
      final result = notifier.loadResult as AnnuityPaymentResult;
      expect(result.monthlyPayment, 1000.0);
      expect(result.totalPayment, 1000.0 * 12);
      expect(result.interestOverpayment, closeTo(1000.0 * 12 - 100000, 0.001));
      // Проверяем, что в репозитории сохранено значение аннуитетного платежа
      expect(fakePreferences.savedAnnuity, 1000.0);
    });

    test('should calculate differentiated payments correctly', () async {
      final loan = Loan(principal: 100000, termInMonths: 12, annualInterestRate: 12);
      await notifier.calculatePayments(loan, DifferentiatedPayment());
      // FakeCalculator возвращает список из 12 элементов, каждый равен 900.0
      expect(notifier.differentiatedPayments.length, equals(12));
      expect(notifier.differentiatedPayments.every((p) => p == 900.0), isTrue);
      expect(notifier.loadResult, isA<DifferentiatedPaymentResult>());
      final result = notifier.loadResult as DifferentiatedPaymentResult;
      expect(result.monthlyPayments.length, equals(12));
      final totalPayment = result.monthlyPayments.reduce((a, b) => a + b);
      expect(result.totalPayment, closeTo(totalPayment, 0.001));
      expect(result.interestOverpayment, closeTo(totalPayment - 100000, 0.001));
      // Проверяем, что в репозитории сохранен список дифференцированных платежей
      expect(fakePreferences.savedDifferentiated, isNotNull);
      expect(fakePreferences.savedDifferentiated!.length, equals(12));
      expect(fakePreferences.savedDifferentiated!.every((p) => p == 900.0), isTrue);
    });
  });
}
