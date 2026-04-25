import 'package:audioplayers/audioplayers.dart';

/// Plays a short tick sound on each tasbih tap as an alternative tactile
/// cue when the OS-level vibration toggle is off.
///
/// Audio is routed through the media channel (not the UI/touch-sounds
/// channel), so on Android it bypasses the system "Touch sounds" toggle.
/// On iOS it follows the ringer/silent switch by default — that's the
/// expected behaviour for a dhikr app (silent in mosque, audible elsewhere).
class TickSoundService {
  TickSoundService._();

  static const _assets = <String>[
    'sounds/tick_click.mp3',
    'sounds/tick_wood.mp3',
    'sounds/tick_tap.mp3',
  ];

  static const styleNames = <String>['Click', 'Wood', 'Soft tap'];

  // One pre-warmed player per style. Pre-warming avoids a 200-300 ms
  // first-play delay when the user starts tapping.
  static final List<AudioPlayer> _players = List.generate(
    _assets.length,
    (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
  );

  static bool _initialized = false;

  /// Pre-load all three tick sounds so the first tap is instant.
  /// Call once on app startup.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    for (var i = 0; i < _assets.length; i++) {
      try {
        await _players[i].setSource(AssetSource(_assets[i]));
        await _players[i].setPlayerMode(PlayerMode.lowLatency);
      } catch (_) {
        // Asset missing or platform doesn't support audio — silently ignore;
        // play() below also catches.
      }
    }
  }

  /// Play the tick at the given style index. No-op if init failed or the
  /// asset is missing on the platform (e.g. web).
  static Future<void> play(int styleIndex) async {
    final i = styleIndex.clamp(0, _assets.length - 1);
    try {
      await _players[i].stop();
      await _players[i].resume();
    } catch (_) {
      // Best-effort. Don't crash the tap handler.
    }
  }

  static Future<void> dispose() async {
    for (final p in _players) {
      try {
        await p.dispose();
      } catch (_) {}
    }
  }
}
