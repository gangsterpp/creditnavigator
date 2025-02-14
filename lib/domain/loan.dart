class Loan {
  /// Сумма кредита
  final int principal;

  /// Годовая процентная ставка (в %)
  final double annualInterestRate;

  /// Срок кредита в месяцах
  final int termInMonths;

  const Loan({
    required this.principal,
    required this.annualInterestRate,
    required this.termInMonths,
  });
}
