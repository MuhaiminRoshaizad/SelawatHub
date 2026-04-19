/// Per-day data model used by the stats feature.
class DayData {
  final int selawat;
  final int zikir;
  final List<(String name, String category, int count)> topDhikr;

  const DayData({
    required this.selawat,
    required this.zikir,
    required this.topDhikr,
  });

  int get total => selawat + zikir;
  int get level {
    if (total == 0) return 0;
    if (total < 200) return 1;
    if (total < 600) return 2;
    if (total < 1200) return 3;
    return 4;
  }
}
