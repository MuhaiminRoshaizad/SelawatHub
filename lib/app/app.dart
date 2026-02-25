import 'package:flutter/material.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/core/theme/app_theme.dart';

class SelawatHubApp extends StatelessWidget {
  const SelawatHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SelawatHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}

