import 'package:flutter/cupertino.dart';

// ─────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────

String capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

IconData categoryIcon(String cat) => switch (cat) {
      'daily' => CupertinoIcons.sun_max,
      'prayer' => CupertinoIcons.heart,
      'protection' => CupertinoIcons.shield,
      'hardship' => CupertinoIcons.flame,
      'social' => CupertinoIcons.person_2,
      'family' => CupertinoIcons.house,
      'death' => CupertinoIcons.moon_stars,
      'ramadan' => CupertinoIcons.moon,
      'travel' => CupertinoIcons.airplane,
      _ => CupertinoIcons.star,
    };
