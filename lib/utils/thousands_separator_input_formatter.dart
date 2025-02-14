import 'package:flutter/services.dart';

/// Кастомный форматтер, который добавляет пробелы как разделитель тысяч.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\s+'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final StringBuffer buffer = StringBuffer();
    int len = digitsOnly.length;
    for (int i = 0; i < len; i++) {
      int positionFromRight = len - i;
      buffer.write(digitsOnly[i]);

      if (positionFromRight > 1 && positionFromRight % 3 == 1) {
        buffer.write(' ');
      }
    }
    String formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
