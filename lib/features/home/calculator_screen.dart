import 'package:creditnavigator/domain/loan.dart';
import 'package:creditnavigator/domain/loan_calculator.dart';
import 'package:creditnavigator/domain/payments_type.dart';
import 'package:creditnavigator/features/history/history_screen.dart';
import 'package:creditnavigator/features/home/monthly_payments_chart.dart';
import 'package:creditnavigator/features/home/payment_type_widget.dart';
import 'package:creditnavigator/features/home/result_card.dart';
import 'package:creditnavigator/notifiers/payment_notifier.dart';
import 'package:creditnavigator/providers/preferences_provider.dart';
import 'package:creditnavigator/utils/custom_decimal_text_input_formatter.dart';
import 'package:creditnavigator/utils/thousands_separator_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _selectedPaymentType = ValueNotifier<PaymentsType>(AnnuityPayment());

  /// Сумма кредита
  final _principal = TextEditingController();

  /// Годовая процентная ставка (в %)
  final _annualInterestRate = TextEditingController();

  /// Срок кредита в месяцах
  final _termInMonths = TextEditingController();

  PaymentNotifier? _paymentNotifier;

  String? get _principalError {
    return int.tryParse(_principal.text.replaceAll(RegExp(r'\s+'), '')) == null ? ' ' : null;
  }

  bool get _principalHasError {
    return _principalError != null;
  }

  String? get _annualInterestRateError {
    return double.tryParse(_annualInterestRate.text) == null ? ' ' : null;
  }

  bool get _annualInterestRateHasError {
    return _annualInterestRateError != null;
  }

  String? get _termInMonthsError {
    return int.tryParse(_termInMonths.text) == null ? ' ' : null;
  }

  bool get _termInMonthsHasError {
    return _termInMonthsError != null;
  }

  bool get _isDisabled => _principalHasError || _annualInterestRateHasError || _termInMonthsHasError;

  late final listenableAll = Listenable.merge(
    [
      _principal,
      _annualInterestRate,
      _termInMonths,
    ],
  );

  @override
  void initState() {
    super.initState();
    _selectedPaymentType.addListener(_calculate);
  }

  void _calculate() {
    if (_isDisabled) return;
    final principal = int.parse(_principal.text.replaceAll(RegExp(r'\s+'), ''));
    final annualInterestRate = double.parse(_annualInterestRate.text);
    final termInMonths = int.parse(_termInMonths.text);
    _paymentNotifier?.calculatePayments(
      Loan(
        principal: principal,
        annualInterestRate: annualInterestRate,
        termInMonths: termInMonths,
      ),
      _selectedPaymentType.value,
    );
  }

  @override
  void didChangeDependencies() {
    _paymentNotifier ??= PaymentNotifier(
      calculator: LoanCalculatorImpl(),
      preferencesRepository: PreferencesProvider.of(context),
    )..addListener(__paymentListener);
    super.didChangeDependencies();
  }

  void __paymentListener() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (_paymentNotifier?.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_paymentNotifier!.errorMessage!)));
    }
  }

  @override
  void dispose() {
    _selectedPaymentType.removeListener(_calculate);
    _paymentNotifier?.removeListener(__paymentListener);
    _paymentNotifier?.dispose();
    _principal.dispose();
    _annualInterestRate.dispose();
    _termInMonths.dispose();
    _selectedPaymentType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Кредитный калькулятор'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, HistoryScreen.path);
            },
            icon: Icon(
              Icons.watch_later_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            ListenableBuilder(
                listenable: _principal,
                builder: (c, _) {
                  return TextField(
                    controller: _principal,
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    inputFormatters: [
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      errorText: _principalError,
                      border: OutlineInputBorder(),
                      labelText: 'Сумма кредита',
                    ),
                  );
                }),
            SizedBox(height: 20),
            ListenableBuilder(
              listenable: _annualInterestRate,
              builder: (c, _) {
                return TextField(
                  controller: _annualInterestRate,
                  inputFormatters: [
                    CustomDecimalTextInputFormatter(),
                  ],
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    errorText: _annualInterestRateError,
                    labelText: 'Процентная ставка',
                    hintText: '18.2',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ListenableBuilder(
              listenable: _termInMonths,
              builder: (c, _) {
                return TextField(
                  controller: _termInMonths,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d')),
                  ],
                  decoration: InputDecoration(
                    errorText: _termInMonthsError,
                    labelText: 'Срок кредита в мес.',
                    hintText: '12',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ListenableBuilder(
                listenable: listenableAll,
                builder: (c, _) {
                  return PaymentTypeWidget(notifier: _selectedPaymentType, isDisabled: _isDisabled);
                }),
            SizedBox(height: 20),
            ListenableBuilder(
                listenable: listenableAll,
                builder: (context, _) {
                  return ElevatedButton.icon(
                    onPressed: _isDisabled ? null : _calculate,
                    icon: Icon(
                      Icons.calculate,
                    ),
                    label: Text('Рассчитать'),
                  );
                }),
            SizedBox(height: 20),
            ListenableBuilder(
              listenable: _paymentNotifier!,
              builder: (c, _) {
                return ResultCard(paymentResult: _paymentNotifier?.loadResult);
              },
            ),
            ListenableBuilder(
              listenable: _paymentNotifier!,
              builder: (c, _) {
                switch (_paymentNotifier?.loadResult) {
                  case DifferentiatedPaymentResult d:
                    return SimpleMonthlyPaymentsChart(monthlyPayments: d.monthlyPayments);

                  default:
                    return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
