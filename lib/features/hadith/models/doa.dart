/// A single doa (supplication) entry.
class Doa {
  const Doa({
    required this.arabic,
    required this.translation,
    required this.category,
    required this.source,
  });

  final String arabic;
  final String translation;
  final DoaCategory category;
  final String source;
}

enum DoaCategory {
  morningEvening,
  afterSolat,
  protection,
  dailyEssentials,
}

/// A single hadith entry.
class Hadith {
  const Hadith({
    required this.text,
    required this.source,
    required this.topic,
  });

  final String text;
  final String source;
  final String topic;
}
