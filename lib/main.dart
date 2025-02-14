import 'dart:async';
import 'dart:developer';

import 'package:creditnavigator/app.dart';
import 'package:creditnavigator/domain/preferences_repository.dart';
import 'package:creditnavigator/providers/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      initializeDateFormatting('ru_RU');
      final prefs = PreferencesRepositoryImpl(await SharedPreferences.getInstance());
      runApp(
        PreferencesProvider(
          preferencesRepository: prefs,
          child: App(),
        ),
      );
    },
    (e, s) {
      log(
        'ОШИБКА',
        error: e,
        stackTrace: s,
        time: DateTime.now(),
      );
    },
  );
}
