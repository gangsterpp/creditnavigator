import 'package:creditnavigator/domain/loan_calculator.dart';
import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final PaymentCalculationResult? paymentResult;
  const ResultCard({super.key, required this.paymentResult});

  @override
  Widget build(BuildContext context) {
    if (paymentResult == null) return SizedBox.shrink();
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          SizedBox(height: Theme.of(context).dividerTheme.space),
          switch (paymentResult!) {
            AnnuityPaymentResult a => ListTile(
                title: Text('Ежемесячный платёж'),
                subtitle: Text('${a.monthlyPayment}'),
              ),
            DifferentiatedPaymentResult d => ListTile(
                title: Text('Ежемесячный платёж'),
                subtitle: Text('Показать график'),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    )),
                    builder: (context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                Text(
                                  "Структура выплат",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                for (int i = 0; i < d.monthlyPayments.length; i++)
                                  Text(
                                    '${i + 1} месяц: ${d.monthlyPayments[i].toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          },
          Divider(),
          ListTile(
            title: Text('Общая сумма выплат'),
            subtitle: Text('${paymentResult?.totalPayment}'),
          ),
          Divider(),
          ListTile(
            title: Text('Переплата по процентам'),
            subtitle: Text('${paymentResult?.interestOverpayment}'),
          ),
          SizedBox(height: Theme.of(context).dividerTheme.space),
        ],
      ),
    );
  }
}
