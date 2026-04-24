import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selawathub/features/hadith/models/doa.dart';

/// Service for fetching doa, hadith, adkar, and post-salaah data
/// from the Naikiyah API.
///
/// Caching strategy (stale-while-revalidate):
///  - Results are cached in memory for the lifetime of the app.
///  - Results are also persisted to SharedPreferences under
///    [_kCachePrefix], along with a timestamp.
///  - On fetch, we immediately return cached data if available, even if
///    it's stale. A background refresh is kicked off when the cache is
///    older than [_cacheTtl] (24h) to avoid daily re-fetches.
///  - If the network request fails, the stale cache is still returned.
class DoaApiService {
  DoaApiService._();
  static final instance = DoaApiService._();

  static const _base = 'https://dua-data-api.vercel.app/api';
  static const _kCachePrefix = 'doa_cache_';
  static const _kTimestampPrefix = 'doa_cache_ts_';
  static const _cacheTtl = Duration(hours: 24);

  // In-memory caches — populated lazily from prefs on first access.
  List<Doa>? _duasCache;
  List<NawawiHadith>? _hadithsCache;
  List<DailyAdkar>? _adkarCache;
  List<PostSalaahZikr>? _postSalaahCache;

  // In-flight requests for deduping concurrent refreshes.
  Future<void>? _duasRefresh;
  Future<void>? _hadithsRefresh;
  Future<void>? _adkarRefresh;
  Future<void>? _postSalaahRefresh;

  // ── Public fetchers ──

  Future<List<Doa>> fetchDuas() async {
    await _hydrateIfNeeded<Doa>(
      key: 'duas',
      current: _duasCache,
      parse: (json) => (json as List)
          .map((e) => Doa.fromJson(e as Map<String, dynamic>))
          .toList(),
      assign: (v) => _duasCache = v,
    );
    _maybeRefreshDuas();
    if (_duasCache == null) await _duasRefresh;
    return _duasCache ?? const [];
  }

  Future<List<NawawiHadith>> fetchHadiths() async {
    await _hydrateIfNeeded<NawawiHadith>(
      key: 'hadiths',
      current: _hadithsCache,
      parse: (json) => (json as List)
          .map((e) => NawawiHadith.fromJson(e as Map<String, dynamic>))
          .toList(),
      assign: (v) => _hadithsCache = v,
    );
    _maybeRefreshHadiths();
    if (_hadithsCache == null) await _hadithsRefresh;
    return _hadithsCache ?? const [];
  }

  Future<List<DailyAdkar>> fetchDailyAdkar() async {
    await _hydrateIfNeeded<DailyAdkar>(
      key: 'adkar',
      current: _adkarCache,
      parse: (json) => (json as List)
          .map((e) => DailyAdkar.fromJson(e as Map<String, dynamic>))
          .toList(),
      assign: (v) => _adkarCache = v,
    );
    _maybeRefreshAdkar();
    if (_adkarCache == null) await _adkarRefresh;
    return _adkarCache ?? const [];
  }

  Future<List<PostSalaahZikr>> fetchPostSalaah() async {
    await _hydrateIfNeeded<PostSalaahZikr>(
      key: 'postSalaah',
      current: _postSalaahCache,
      parse: (json) => (json as List)
          .map((e) => PostSalaahZikr.fromJson(e as Map<String, dynamic>))
          .toList(),
      assign: (v) => _postSalaahCache = v,
    );
    _maybeRefreshPostSalaah();
    if (_postSalaahCache == null) await _postSalaahRefresh;
    return _postSalaahCache ?? const [];
  }

  // ── Cache hydration ──

  /// Loads persisted JSON from prefs into the in-memory cache if it's empty.
  /// This is cheap (sync prefs read + jsonDecode on a background
  /// microtask). No network call happens here.
  Future<void> _hydrateIfNeeded<T>({
    required String key,
    required List<T>? current,
    required List<T> Function(dynamic json) parse,
    required void Function(List<T> value) assign,
  }) async {
    if (current != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kCachePrefix$key');
    if (raw == null) return;
    try {
      assign(parse(jsonDecode(raw)));
    } catch (_) {
      // Corrupt cache — discard so the next fetch overwrites it.
      await prefs.remove('$_kCachePrefix$key');
      await prefs.remove('$_kTimestampPrefix$key');
    }
  }

  Future<bool> _isStale(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt('$_kTimestampPrefix$key');
    if (ts == null) return true;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    return age > _cacheTtl.inMilliseconds;
  }

  // ── Background refresh triggers ──

  void _maybeRefreshDuas() {
    if (_duasRefresh != null) return;
    _duasRefresh = () async {
      try {
        if (_duasCache != null && !await _isStale('duas')) return;
        final res = await http.get(Uri.parse('$_base/usefulDuas'));
        if (res.statusCode != 200) return;
        final List<dynamic> data = jsonDecode(res.body);
        _duasCache =
            data.map((e) => Doa.fromJson(e as Map<String, dynamic>)).toList();
        await _persist('duas', res.body);
      } catch (_) {
        // Swallow — stale cache (if any) still serves reads.
      } finally {
        _duasRefresh = null;
      }
    }();
  }

  void _maybeRefreshHadiths() {
    if (_hadithsRefresh != null) return;
    _hadithsRefresh = () async {
      try {
        if (_hadithsCache != null && !await _isStale('hadiths')) return;
        final res = await http.get(Uri.parse('$_base/fortyNawawi'));
        if (res.statusCode != 200) return;
        final List<dynamic> data = jsonDecode(res.body);
        _hadithsCache = data
            .map((e) => NawawiHadith.fromJson(e as Map<String, dynamic>))
            .toList();
        await _persist('hadiths', res.body);
      } catch (_) {
      } finally {
        _hadithsRefresh = null;
      }
    }();
  }

  void _maybeRefreshAdkar() {
    if (_adkarRefresh != null) return;
    _adkarRefresh = () async {
      try {
        if (_adkarCache != null && !await _isStale('adkar')) return;
        final res = await http.get(Uri.parse('$_base/dailyAdkar'));
        if (res.statusCode != 200) return;
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isEmpty) return;
        final Map<String, dynamic> first = data[0] as Map<String, dynamic>;
        final List<dynamic> duas = first['duas'] as List<dynamic>? ?? [];
        _adkarCache = duas
            .map((e) => DailyAdkar.fromJson(e as Map<String, dynamic>))
            .toList();
        // Persist the normalized inner list — not the wrapper — so hydrate
        // can parse it symmetrically.
        await _persist('adkar', jsonEncode(duas));
      } catch (_) {
      } finally {
        _adkarRefresh = null;
      }
    }();
  }

  void _maybeRefreshPostSalaah() {
    if (_postSalaahRefresh != null) return;
    _postSalaahRefresh = () async {
      try {
        if (_postSalaahCache != null && !await _isStale('postSalaah')) return;
        final res = await http.get(Uri.parse('$_base/postSalaah'));
        if (res.statusCode != 200) return;
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isEmpty) return;
        final Map<String, dynamic> first = data[0] as Map<String, dynamic>;
        final List<dynamic> zikr = first['zikr'] as List<dynamic>? ?? [];
        _postSalaahCache = zikr
            .map((e) => PostSalaahZikr.fromJson(e as Map<String, dynamic>))
            .toList();
        await _persist('postSalaah', jsonEncode(zikr));
      } catch (_) {
      } finally {
        _postSalaahRefresh = null;
      }
    }();
  }

  Future<void> _persist(String key, String jsonBody) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kCachePrefix$key', jsonBody);
    await prefs.setInt(
      '$_kTimestampPrefix$key',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
