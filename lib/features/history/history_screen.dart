import 'package:creditnavigator/domain/history_data.dart';
import 'package:creditnavigator/providers/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DifferentiatedPaymentsDisplay extends StatefulWidget {
  final List<String> payments;

  const DifferentiatedPaymentsDisplay({super.key, required this.payments});

  @override
  State<DifferentiatedPaymentsDisplay> createState() => _DifferentiatedPaymentsDisplayState();
}

class _DifferentiatedPaymentsDisplayState extends State<DifferentiatedPaymentsDisplay> {
  bool _expanded = false;
  List<Widget> _paymentWidgets = [];

  void _updatePaymentWidgets() {
    final List<Widget> widgets = [];
    final payments = widget.payments;

    if (payments.length == 1) {
      widgets.add(
        Text(
          '1 месяц: ${payments.first}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    } else {
      if (payments.length <= 3 || _expanded) {
        for (int i = 0; i < payments.length; i++) {
          widgets.add(
            Text(
              '${i + 1} месяц: ${payments[i]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (_expanded && payments.length > 3) {
          widgets.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = false;
                  _updatePaymentWidgets();
                });
              },
              child: Text(
                'Свернуть',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        }
      } else {
        for (int i = 0; i < 3; i++) {
          widgets.add(
            Text(
              '${i + 1} месяц: ${payments[i]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        widgets.add(
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = true;
                _updatePaymentWidgets();
              });
            },
            child: Text(
              'Показать ещё ${payments.length - 3} платежей',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      }
    }
    _paymentWidgets = widgets;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePaymentWidgets();
  }

  @override
  void didUpdateWidget(covariant DifferentiatedPaymentsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payments != widget.payments) {
      _expanded = false;
      _updatePaymentWidgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payments.isEmpty) return const SizedBox.shrink();
    return Column(
      key: ValueKey(_paymentWidgets.length),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _paymentWidgets,
    );
  }
}

class HistoryScreen extends StatelessWidget {
  static const path = '/history';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = PreferencesProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('История запросов'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<HistoryData>>(
          future: preferences.loadAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Ошибка загрузки данных',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Center(
                child: Text(
                  'История пуста',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      DateFormat('dd MMMM yyyy', 'ru_RU').format(item.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.annuityPayment != null)
                            Text(
                              'Аннуитетный платеж: ${item.annuityPayment!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          if (item.differentiatedPayments != null)
                            DifferentiatedPaymentsDisplay(
                              payments: item.differentiatedPayments!,
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
      ),
    );
  }
}
