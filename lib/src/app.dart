import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'application/ssh_config_controller.dart';
import 'data/services/ssh_config_service.dart';
import 'data/services/ssh_connection_service.dart';
import 'l10n/app_localizations.dart';
import 'presentation/pages/ssh_config_page.dart';

class SshManagerApp extends StatefulWidget {
  const SshManagerApp({super.key});

  @override
  State<SshManagerApp> createState() => _SshManagerAppState();
}

class _SshManagerAppState extends State<SshManagerApp> {
  late final SshConfigController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SshConfigController(
      configService: const SshConfigService(),
      connectionService: const SshConnectionService(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B7A75)),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return const Locale('en');
        }

        final isRussian = locale.languageCode.toLowerCase() == 'ru';
        return isRussian ? const Locale('ru') : const Locale('en');
      },
      home: SshConfigPage(controller: _controller),
    );
  }
}
