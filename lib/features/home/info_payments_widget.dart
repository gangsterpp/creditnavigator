import 'package:creditnavigator/domain/loan_calculator.dart';
import 'package:creditnavigator/domain/payment_info.dart';
import 'package:creditnavigator/providers/payment_provider.dart';
import 'package:flutter/material.dart';

class InfoPaymentsWidget extends StatelessWidget {
  final String title;
  final PaymentInfo paymentType;
  const InfoPaymentsWidget({
    super.key,
    required this.title,
    required this.paymentType,
  });

  String monthlyPayment(BuildContext context) {
    return '0';
  }

  @override
  Widget build(BuildContext context) {
    final payment = PaymentProvider.of(context);
    final value = switch (paymentType) {
      PaymentInfo.totalPayment => '${payment?.totalPayment.toStringAsFixed(2) ?? 0}',
      PaymentInfo.monthlyPayment => monthlyPayment(context),
      PaymentInfo.interestOverpayment => '${payment?.interestOverpayment.toStringAsFixed(2) ?? 0}',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        switch (payment) {
          AnnuityPaymentResult() => Flexible(
              child: Text(
                textAlign: TextAlign.right,
                value,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          _ => SizedBox.shrink(),
        },
      ],
    );
  }
}
