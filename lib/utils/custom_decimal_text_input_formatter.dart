import 'package:flutter/services.dart';

/// Кастомный форматтер:
/// - Разрешает ввод цифр [0-9]
/// - Разрешает ввести ровно одну точку или запятую в любом месте
/// - Разрешает максимум [decimalRange] цифр после точки
/// - Если символ не подходит, он просто отбрасывается, без сброса всего значения
class CustomDecimalTextInputFormatter extends TextInputFormatter {
  /// Сколько знаков после точки (запятой) разрешаем
  final int decimalRange;

  CustomDecimalTextInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = newValue.text;

    final StringBuffer newBuffer = StringBuffer();

    bool hasDecimalPoint = false; // Уже встречали точку?
    int decimalDigitsCount = 0; // Сколько цифр уже после точки?

    // Проходим посимвольно по новой строке
    for (int i = 0; i < newText.length; i++) {
      final String char = newText[i];

      // Проверка: цифра ли это?
      if (RegExp(r'[0-9]').hasMatch(char)) {
        // Если точка ещё не встречалась — свободно добавляем
        if (!hasDecimalPoint) {
          newBuffer.write(char);
        } else {
          // Если уже есть точка, проверяем, не превысили ли лимит знаков после неё
          if (decimalDigitsCount < decimalRange) {
            newBuffer.write(char);
            decimalDigitsCount++;
          }
          // Иначе (лишний знак) — пропускаем
        }
      }
      // Проверка: точка или запятая, и ещё не встречали точку — разрешаем
      else if ((char == '.' || char == ',') && !hasDecimalPoint) {
        newBuffer.write('.'); // Записываем именно точку, даже если ввели запятую
        hasDecimalPoint = true;
      }
      // Иначе пропускаем символ (не digits, не точка — игнорируем)
    }

    final String filteredText = newBuffer.toString();

    int newCursorPosition = 0;
    {
      bool hasDecimalPointTemp = false;
      int decimalDigitsCountTemp = 0;

      for (int i = 0; i < newValue.selection.end && i < newText.length; i++) {
        final String char = newText[i];

        if (RegExp(r'[0-9]').hasMatch(char)) {
          if (!hasDecimalPointTemp) {
            newCursorPosition++;
          } else {
            if (decimalDigitsCountTemp < decimalRange) {
              newCursorPosition++;
              decimalDigitsCountTemp++;
            }
          }
        } else if ((char == '.' || char == ',') && !hasDecimalPointTemp) {
          newCursorPosition++;
          hasDecimalPointTemp = true;
        }
      }
    }

    if (newCursorPosition > filteredText.length) {
      newCursorPosition = filteredText.length;
    }

    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
