import 'package:creditnavigator/domain/loan_calculator.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends InheritedWidget {
  final PaymentCalculationResult? data;
  const PaymentProvider({
    super.key,
    required super.child,
    required this.data,
  });

  @override
  bool updateShouldNotify(PaymentProvider oldWidget) {
    return data != oldWidget.data;
  }

  static PaymentCalculationResult? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PaymentProvider>()?.data;
  }
}
