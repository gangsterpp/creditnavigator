import 'package:creditnavigator/domain/payments_type.dart';
import 'package:flutter/material.dart';

class PaymentTypeWidget extends StatelessWidget {
  final ValueNotifier<PaymentsType> notifier;
  final bool isDisabled;
  const PaymentTypeWidget({super.key, required this.notifier, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: notifier,
        builder: (_, type, __) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Expanded(
                child: ChoiceChip(
                  onSelected: isDisabled
                      ? null
                      : (value) {
                          notifier.value = AnnuityPayment();
                        },
                  label: Text('Аннуитетный'),
                  selected: type is AnnuityPayment,
                ),
              ),
              Expanded(
                child: ChoiceChip(
                  onSelected: isDisabled
                      ? null
                      : (value) {
                          notifier.value = DifferentiatedPayment();
                        },
                  label: Text(
                    'Дифференцированный',
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                  ),
                  selected: type is DifferentiatedPayment,
                ),
              ),
            ],
          );
        });
  }
}
