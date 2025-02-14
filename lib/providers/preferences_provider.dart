import 'package:creditnavigator/domain/preferences_repository.dart';
import 'package:flutter/material.dart';

class PreferencesProvider extends InheritedWidget {
  final PreferencesRepository preferencesRepository;
  const PreferencesProvider({super.key, required super.child, required this.preferencesRepository});

  @override
  bool updateShouldNotify(PreferencesProvider oldWidget) {
    return preferencesRepository != oldWidget.preferencesRepository;
  }

  static PreferencesRepository of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PreferencesProvider>()!.preferencesRepository;
  }
}
