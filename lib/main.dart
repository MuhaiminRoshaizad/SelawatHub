import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selawathub/app/app.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/services/tick_sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  await SettingsService.init();
  // Pre-warm tick sound players so the first tap doesn't have a startup
  // delay. Won't fail if assets are missing — play() is best-effort.
  unawaited(TickSoundService.init());
  runApp(const ProviderScope(child: SelawatHubApp()));
}
