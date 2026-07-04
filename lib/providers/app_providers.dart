// lib/providers/app_providers.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'run_provider.dart';
import 'profile_provider.dart';
import 'settings_provider.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<RunProvider>(
          create: (_) => RunProvider(),
        ),
      ];
}
