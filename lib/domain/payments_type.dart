sealed class PaymentsType {
  String get value;
  const PaymentsType();
  static const values = [
    AnnuityPayment(),
    DifferentiatedPayment(),
  ];
}

class AnnuityPayment extends PaymentsType {
  const AnnuityPayment();

  @override
  String get value => 'Аннуитетный';
}

class DifferentiatedPayment extends PaymentsType {
  const DifferentiatedPayment();

  @override
  String get value => 'Дифференцированный';
}
