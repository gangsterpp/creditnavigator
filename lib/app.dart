import 'package:creditnavigator/features/history/history_screen.dart';
import 'package:creditnavigator/features/home/calculator_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return MaterialApp(
      title: 'Кредитный калькулятор',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        fontFamily: 'Roboto',
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF3498DB),
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.expressive,
        ),
      ),
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF3498DB),
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.expressive,
        ),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == HistoryScreen.path) return MaterialPageRoute(builder: (c) => HistoryScreen(), settings: settings);
        return MaterialPageRoute(builder: (c) => CalculatorScreen(), settings: settings);
      },
      home: CalculatorScreen(),
    );
  }
}
