import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selawathub/app/app.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  await SettingsService.init();
  runApp(const ProviderScope(child: SelawatHubApp()));
}
