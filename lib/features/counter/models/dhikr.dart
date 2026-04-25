/// Categories for dhikr items.
enum DhikrCategory { selawat, zikir }

/// A single dhikr/selawat with Arabic text, transliteration, and target count.
class Dhikr {
  final String id;
  final String arabic;
  final String transliteration;
  final String name;
  final int defaultTarget;
  final DhikrCategory category;

  const Dhikr({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.name,
    required this.defaultTarget,
    required this.category,
  });

  /// User-defined dhikr. Arabic/transliteration are empty because the user
  /// hasn't supplied them — only the [name] and [category] are meaningful.
  /// [id] should be `custom:<slug>` where slug is derived from the name.
  factory Dhikr.custom({
    required String id,
    required String name,
    required DhikrCategory category,
    int defaultTarget = 100,
  }) =>
      Dhikr(
        id: id,
        arabic: '',
        transliteration: '',
        name: name,
        defaultTarget: defaultTarget,
        category: category,
      );

  bool get isCustom => id.startsWith('custom:');

  /// Convert a user-entered display name into a stable dhikr_id suffix.
  /// Lowercased, non-alphanumerics collapsed to single hyphens, trimmed.
  /// E.g. "Selawat Munjiyat!" -> "custom:selawat-munjiyat".
  static String slugify(String raw) {
    final lower = raw.trim().toLowerCase();
    final sb = StringBuffer();
    var lastDash = true;
    for (final r in lower.runes) {
      final c = String.fromCharCode(r);
      final isAlphaNum = RegExp(r'[a-z0-9]').hasMatch(c);
      if (isAlphaNum) {
        sb.write(c);
        lastDash = false;
      } else if (!lastDash) {
        sb.write('-');
        lastDash = true;
      }
    }
    var s = sb.toString();
    if (s.endsWith('-')) s = s.substring(0, s.length - 1);
    return 'custom:$s';
  }

  static const List<Dhikr> all = [...selawatList, ...zikirList];

  static const List<Dhikr> selawatList = [
    Dhikr(
      id: 'selawat-jibril',
      arabic: 'صَلَّى اللهُ عَلَى مُحَمَّد',
      transliteration: 'Sallallahu ala Muhammad.',
      name: 'Selawat Jibril',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-tadzimul-qiyam',
      arabic: 'اللهم صَلِّ عَلى مُحَمَّدٍ وَّعَلى الِه وَسَلِّم',
      transliteration: 'Allahumma salli ala Muhammad wa ala alihi wa sallim.',
      name: "Selawat Ta'dzhimul Qiyam",
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-tibbil-qulub',
      arabic:
          'صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ طِبِّ الْقُلُوْبِ وَدَوَائِهَا وَعَافِيَةِ الأَبْدَانِ وَشِفَائِهَا وَنُوْرِ الأَبْصَارِ وَضِيَائِهَا وَعَلٰى آَلِهِ وَصَحْبِهِ وَبَارِكْ وَسَلِّمْ',
      transliteration:
          'Salli ala sayyidina Muhammad tibbil qulubi wa dawa iha wa afiyatil abdani wa shifa iha wa nuril absari wa dhiya iha wa ala alihi wa sahbihi wa barik wa sallim.',
      name: 'Selawat Tibbil Qulub',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-nuril-anwar',
      arabic:
          'اَللَّهُمَّ صَلِّ عَلَى نُوْرِ اْلاَنْوَارِ وَسِرِّ اْلاَسْرَارِ وَتِرْيَاقِ اْلاَغْيَارِ وَمِفتَاحِ بَابِ الْيَسَارِ سَيِّدِنَا وَمَوْلاَنَا مُحَمَّدِ نِالْمُخْتَارِ وَالِهِ اْلاَطْهَرِ وَاَصْحَابِهِ اْلاَخْيَارِ عَدَدَ نِعَمِ اللّهِ وَاِفضَالِهِ',
      transliteration:
          'Allahumma salli ala nuril anwar wa sirril asrar wa tiryaqil aghyar wa miftahi babil yasar sayyidina wa maulana Muhammadin al-mukhtar wa alihi al-athhar wa ashabihi al-akhyar adada ni amillahi wa ifdhaalih.',
      name: 'Selawat Nuril Anwar',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-al-fatih',
      arabic:
          'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى سَيِّدِنَا مُحَمَّدٍ الفَاتِحِ لِمَا أُغْلِقَ وَالخَاتِمِ لِمَا سَبَقَ وَالنَّاصِرِ الحَقَّ بِالحَقِّ وَالهَادِي اِلَى صِرَاطٍ مُسْتَقِيْمٍ. صَلَّى اللهُ عَلَيْهِ وَعَلَى اَلِهِ وَأَصْحَابِهَ حَقَّ قَدْرِهِ وَمِقْدَارِهِ العَظِيْمِ',
      transliteration:
          'Allahumma salli wa sallim wa barik ala sayyidina Muhammadil fatihi lima ughliq wal khatimi lima sabaq wan nasiril haqqa bil haqq wal hadi ila siratin mustaqim. Sallallahu alaihi wa ala alihi wa ashaabihi haqqa qadrihi wa miqdaarihil azim.',
      name: 'Selawat Al-Fatih',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-nariah',
      arabic:
          'اللَّهُمَّ صَلِّ صَلاَةً كَامِلَةً وَسَلِّمْ سَلاَمًا تَامًّا عَلىَ سَيِّدِنَا مُحَمَّدٍ الَّذِيْ تُنْحَلُ بِهَ الْعُقَدُ وَتَنْفَرِجُ بِهِ الْكُرَبُ وَتُقْضَى بِهِ الْحَوَائِجُ وَتُنَالُ بِهِ الرَّغَائِبُ وَحُسْنُ الْخَوَاتِيْمِ وَيُسْتَسْقَى الْغَمَامُ بِوَجْهِهِ الْكَرِيْمِ وَعَلىَ آلِهِ وَصَحْبِهِ عَدَدَ كُلِّ مَعْلُوْمٍ لَكَ',
      transliteration:
          'Allahumma salli salatan kamilatan wa sallim salaman tamman ala sayyidina Muhammadin alladhi tunhalu bihil uqad wa tanfariju bihil kurab wa tuqdha bihil hawa ij wa tunalu bihir ragha ib wa husnul khawatim wa yustasqal ghamamu biwajhihil karim wa ala alihi wa sahbihi adada kulli ma lumin lak.',
      name: 'Selawat Nariah',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-ibrahimiyah',
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ.',
      transliteration:
          'Allahumma salli ala Muhammad wa ala ali Muhammad, kama sallaita ala Ibrahim wa ala ali Ibrahim innaka hamidun majid. Allahumma barik ala Muhammad wa ala ali Muhammad, kama barakta ala Ibrahim wa ala ali Ibrahim innaka hamidun majid.',
      name: 'Selawat Ibrahimiyah',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-tafrijiyah',
      arabic:
          'اَللّٰهُمَّ صَلِّ صَلَاةً كَامِلَةً وَسَلِّمْ سَلَامًا تَامًّا عَلىٰ سَيِّدِنَا مُحَــمَّدِ نِ الَّذِيْ تَنْحَلُّ بِهِ الْعُقَدُ وَتَنْفَرِجُ بِهِ الْكُرَبُ وَتُقْضٰى بِهِ الْحَوَائِجُ وَتُنَالُ بِهِ الرَّغَائِبُ وَحُسْنُ الْخَوَاتِمِ وَيُسْتَسْقَى الْغَمَامُ بِوَجْهِهِ الْكَرِيْمِ وَعَلىٰ اٰلِهِ وِصَحْبِهِ فِيْ كُلِّ لَمْحَةٍ وَ نَفَسٍ بِعَدَدِ كُلِّ مَعْلُوْمٍ لَكَ',
      transliteration:
          'Allahumma salli salatan kamilatan wa sallim salaman tamman ala sayyidina Muhammadin alladhi tanhallu bihil uqad wa tanfariju bihil kurab wa tuqdha bihil hawa ij wa tunalu bihir ragha ib wa husnul khawatim wa yustasqal ghamamu biwajhihil karim wa ala alihi wa sahbihi fi kulli lamhatin wa nafasin bi adadi kulli ma lumin lak.',
      name: 'Selawat Tafrijiyah',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
    Dhikr(
      id: 'selawat-munjiyat',
      arabic:
          'اَللّٰهُمَّ صَلِّ عَلٰى سَيِّدِنَا مُحَمَّدٍ صَلاَةً تُنْجِيْنَا بِهَا مِنْ جَمِيْعِ الْاَهْوَالِ وَالْاٰفَاتِ وَتَقْضِيْ لَنَابِهَا جَمِيعَ الْحَاجَاتِ وَتُطَهِّرُنَا بِهَا مِنْ جَمِيْعِ السَيِّئَاتِ وَتَرْفَعُنَابِهَا عِنْدَكَ اَعْلَى الدَّرَجَاتِ وَتُبَلِّغُنَا بِهَا اَقْصَى الْغَايَاتِ مِنْ جَمِيْعِ الْخَيْرَاتِ فِى الْحَيَاةِ وَبَعْدَ الْمَمَاتِ',
      transliteration:
          'Allahumma salli ala sayyidina Muhammad salatan tunjina biha min jami il ahwali wal afat, wa taqdhi lana biha jami al-hajat, wa tutahhiruna biha min jami is-sayyi at, wa tarfa una biha indaka a la ad-darajat, wa tuballighuna biha aqsa al-ghayat min jami il-khairat fil hayati wa ba dal mamat.',
      name: 'Selawat Munjiyat',
      defaultTarget: 100,
      category: DhikrCategory.selawat,
    ),
  ];

  static const List<Dhikr> zikirList = [
    Dhikr(
      id: 'zikir-subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'Subhanallah',
      name: 'Tasbih',
      defaultTarget: 33,
      category: DhikrCategory.zikir,
    ),
    Dhikr(
      id: 'zikir-alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      name: 'Tahmid',
      defaultTarget: 33,
      category: DhikrCategory.zikir,
    ),
    Dhikr(
      id: 'zikir-allahuakbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      name: 'Takbir',
      defaultTarget: 34,
      category: DhikrCategory.zikir,
    ),
    Dhikr(
      id: 'zikir-istighfar',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      name: 'Istighfar',
      defaultTarget: 100,
      category: DhikrCategory.zikir,
    ),
    Dhikr(
      id: 'zikir-tahlil',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      transliteration: 'La ilaha illallah',
      name: 'Tahlil',
      defaultTarget: 100,
      category: DhikrCategory.zikir,
    ),
    Dhikr(
      id: 'zikir-subhanallahi-wabihamdihi',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'Subhanallahi wa bihamdihi',
      name: 'Tasbih & Tahmid',
      defaultTarget: 100,
      category: DhikrCategory.zikir,
    ),
    Dhikr(
      id: 'zikir-subhanallahil-azim',
      arabic: 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      transliteration: 'Subhanallahil Azim',
      name: 'Tasbih Al-Azim',
      defaultTarget: 100,
      category: DhikrCategory.zikir,
    ),
    Dhikr(
      id: 'zikir-hawqalah',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      transliteration: 'La hawla wa la quwwata illa billah',
      name: 'Hawqalah',
      defaultTarget: 100,
      category: DhikrCategory.zikir,
    ),
  ];
}
