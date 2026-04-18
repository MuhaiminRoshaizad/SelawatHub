import 'package:selawathub/features/hadith/models/doa.dart';

/// Hardcoded hadith collection — will be replaced with API/Supabase later.
const hadiths = [
  Hadith(
    text:
        'Whoever sends blessings upon me once, Allah will send blessings upon him tenfold.',
    source: 'Sahih Muslim 408',
    topic: 'Virtue of Selawat',
  ),
  Hadith(
    text:
        'The closest people to me on the Day of Resurrection will be those who sent the most blessings upon me.',
    source: 'Sunan al-Tirmidhi 484',
    topic: 'Closeness to the Prophet ﷺ',
  ),
  Hadith(
    text:
        'No people sit in a gathering in which they do not remember Allah and send blessings upon the Prophet ﷺ, except it will be a source of regret for them.',
    source: 'Sunan al-Tirmidhi 3380',
    topic: 'Gatherings of Remembrance',
  ),
  Hadith(
    text:
        'Beautify your gatherings by sending blessings upon me, for your blessings upon me will be a light for you on the Day of Resurrection.',
    source: 'Al-Firdaws 921',
    topic: 'Light on Judgement Day',
  ),
  Hadith(
    text:
        'The miser is the one in whose presence I am mentioned, and he does not send blessings upon me.',
    source: 'Sunan al-Tirmidhi 3546',
    topic: 'Generosity in Remembrance',
  ),
];

/// Hardcoded doa collection — will be replaced with API/Supabase later.
const doas = [
  // ── Morning & Evening ──
  Doa(
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    translation:
        'We have reached the morning and at this very time the whole kingdom belongs to Allah. All praise is for Allah. None has the right to be worshipped except Allah alone.',
    category: DoaCategory.morningEvening,
    source: 'Abu Dawud 5071',
  ),
  Doa(
    arabic:
        'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    translation:
        'O Allah, by Your leave we have reached the morning, by Your leave we have reached the evening, by Your leave we live and die, and unto You is our resurrection.',
    category: DoaCategory.morningEvening,
    source: 'Sunan al-Tirmidhi 3391',
  ),
  Doa(
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ',
    translation:
        'O Allah, I ask You for well-being in this world and the Hereafter.',
    category: DoaCategory.morningEvening,
    source: 'Ibn Majah 3871',
  ),

  // ── After Solat ──
  Doa(
    arabic:
        'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    translation:
        'O Allah, help me to remember You, to thank You, and to worship You in the best of manners.',
    category: DoaCategory.afterSolat,
    source: 'Abu Dawud 1522',
  ),
  Doa(
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    translation:
        'Our Lord, give us in this world that which is good and in the Hereafter that which is good, and protect us from the punishment of the Fire.',
    category: DoaCategory.afterSolat,
    source: 'Quran 2:201',
  ),

  // ── Protection ──
  Doa(
    arabic:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    translation:
        'In the Name of Allah, with whose Name nothing on earth or in the heavens can cause harm, and He is the All-Hearing, the All-Knowing.',
    category: DoaCategory.protection,
    source: 'Abu Dawud 5088',
  ),
  Doa(
    arabic:
        'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    translation:
        'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    category: DoaCategory.protection,
    source: 'Sahih Muslim 2708',
  ),

  // ── Daily Essentials ──
  Doa(
    arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    translation:
        'In the Name of Allah, I place my trust in Allah, there is no power and no strength except with Allah.',
    category: DoaCategory.dailyEssentials,
    source: 'Abu Dawud 5095',
  ),
  Doa(
    arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ',
    translation:
        'O Allah, I seek refuge in You from anxiety and grief.',
    category: DoaCategory.dailyEssentials,
    source: 'Sahih al-Bukhari 6369',
  ),
  Doa(
    arabic: 'بِسْمِ اللَّهِ اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ وَأَعُوذُ بِكَ مِنْ شَرِّ هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ',
    translation:
        'In the Name of Allah. O Allah, I ask You for the good of this day and the good of what comes after it, and I seek refuge in You from the evil of this day and the evil of what comes after it.',
    category: DoaCategory.dailyEssentials,
    source: 'Sahih Muslim 2723',
  ),
];

/// Returns a "daily" item by rotating through the list based on the day.
Hadith dailyHadith() => hadiths[DateTime.now().day % hadiths.length];

Doa dailyDoa() => doas[DateTime.now().day % doas.length];

/// Doas grouped by category, preserving insertion order.
Map<DoaCategory, List<Doa>> doasByCategory() {
  final map = <DoaCategory, List<Doa>>{};
  for (final d in doas) {
    map.putIfAbsent(d.category, () => []).add(d);
  }
  return map;
}
