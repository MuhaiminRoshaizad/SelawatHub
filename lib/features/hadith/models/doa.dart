/// A doa from the usefulDuas endpoint.
class Doa {
  const Doa({
    required this.id,
    required this.title,
    required this.description,
    required this.arabic,
    required this.transliteration,
    required this.category,
  });

  final int id;
  final String title;
  final String description;
  final String arabic;
  final String transliteration;
  final String category;

  factory Doa.fromJson(Map<String, dynamic> json) => Doa(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        arabic: json['dua'] as String? ?? '',
        transliteration: json['transliteration'] as String? ?? '',
        category: json['category'] as String? ?? '',
      );
}

/// A hadith from the fortyNawawi endpoint.
class NawawiHadith {
  const NawawiHadith({
    required this.id,
    required this.number,
    required this.title,
    required this.topic,
    required this.arabic,
    required this.translation,
    required this.narrator,
    required this.source,
    required this.explanation,
  });

  final int id;
  final int number;
  final String title;
  final String topic;
  final String arabic;
  final String translation;
  final String narrator;
  final String source;
  final String explanation;

  factory NawawiHadith.fromJson(Map<String, dynamic> json) => NawawiHadith(
        id: (json['id'] as num?)?.toInt() ?? 0,
        number: (json['number'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        arabic: json['arabic'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        narrator: json['narrator'] as String? ?? '',
        source: json['source'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
      );
}

/// A daily adkar item from the dailyAdkar endpoint.
class DailyAdkar {
  const DailyAdkar({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    required this.transliteration,
    required this.times,
    required this.benefit,
  });

  final int id;
  final String title;
  final String arabic;
  final String translation;
  final String transliteration;
  final String times;
  final String benefit;

  factory DailyAdkar.fromJson(Map<String, dynamic> json) {
    final benefits = json['benefits'] as Map<String, dynamic>? ?? {};
    final b1 = benefits['benefitOne'] as String? ?? '';
    final b2 = benefits['benefitTwo'] as String? ?? '';
    final combined = [b1, b2].where((s) => s.isNotEmpty).join('\n');

    return DailyAdkar(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['duaTitle'] as String? ?? '',
      arabic: json['dua'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      times: json['times']?.toString() ?? '',
      benefit: combined,
    );
  }
}

/// A post-salaah zikr item from the postSalaah endpoint.
class PostSalaahZikr {
  const PostSalaahZikr({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    required this.transliteration,
    required this.times,
    required this.benefit,
  });

  final int id;
  final String title;
  final String arabic;
  final String translation;
  final String transliteration;
  final String times;
  final String benefit;

  factory PostSalaahZikr.fromJson(Map<String, dynamic> json) => PostSalaahZikr(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['zikrTitle'] as String? ?? '',
        arabic: json['dua'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        transliteration: json['transliteration'] as String? ?? '',
        times: json['times']?.toString() ?? '',
        benefit: json['benefit'] as String? ?? '',
      );
}
