import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:selawathub/features/hadith/models/doa.dart';

/// Service for fetching doa, hadith, adkar, and post-salaah data
/// from the Naikiyah API. Results are cached in memory after first fetch.
class DoaApiService {
  DoaApiService._();
  static final instance = DoaApiService._();

  static const _base = 'https://dua-data-api.vercel.app/api';

  List<Doa>? _duasCache;
  List<NawawiHadith>? _hadithsCache;
  List<DailyAdkar>? _adkarCache;
  List<PostSalaahZikr>? _postSalaahCache;

  Future<List<Doa>> fetchDuas() async {
    if (_duasCache != null) return _duasCache!;
    try {
      final res = await http.get(Uri.parse('$_base/usefulDuas'));
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      _duasCache = data.map((e) => Doa.fromJson(e as Map<String, dynamic>)).toList();
      return _duasCache!;
    } catch (_) {
      return [];
    }
  }

  Future<List<NawawiHadith>> fetchHadiths() async {
    if (_hadithsCache != null) return _hadithsCache!;
    try {
      final res = await http.get(Uri.parse('$_base/fortyNawawi'));
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      _hadithsCache =
          data.map((e) => NawawiHadith.fromJson(e as Map<String, dynamic>)).toList();
      return _hadithsCache!;
    } catch (_) {
      return [];
    }
  }

  Future<List<DailyAdkar>> fetchDailyAdkar() async {
    if (_adkarCache != null) return _adkarCache!;
    try {
      final res = await http.get(Uri.parse('$_base/dailyAdkar'));
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      if (data.isEmpty) return [];
      final Map<String, dynamic> first = data[0] as Map<String, dynamic>;
      final List<dynamic> duas = first['duas'] as List<dynamic>? ?? [];
      _adkarCache =
          duas.map((e) => DailyAdkar.fromJson(e as Map<String, dynamic>)).toList();
      return _adkarCache!;
    } catch (_) {
      return [];
    }
  }

  Future<List<PostSalaahZikr>> fetchPostSalaah() async {
    if (_postSalaahCache != null) return _postSalaahCache!;
    try {
      final res = await http.get(Uri.parse('$_base/postSalaah'));
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      if (data.isEmpty) return [];
      final Map<String, dynamic> first = data[0] as Map<String, dynamic>;
      final List<dynamic> zikr = first['zikr'] as List<dynamic>? ?? [];
      _postSalaahCache =
          zikr.map((e) => PostSalaahZikr.fromJson(e as Map<String, dynamic>)).toList();
      return _postSalaahCache!;
    } catch (_) {
      return [];
    }
  }
}
