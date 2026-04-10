import 'package:audio_service/audio_service.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// A singleton [AudioHandler] that wraps [AudioPlayer] and exposes it to the
/// OS media notification / lock-screen controls.
///
/// Usage
/// -----
/// 1. Call [BibiAudioHandler.init] once (automatically done in main.dart).
/// 2. Access the singleton via [BibiAudioHandler.instance].
/// 3. Always check if instance is null before using in UI.

class BibiAudioHandler extends BaseAudioHandler with SeekHandler {
  BibiAudioHandler._();

  static BibiAudioHandler? _instance;
  static bool _isInitialized = false;

  /// Initialize the audio handler. Safe to call multiple times.
  /// Returns the singleton instance.
  static Future<BibiAudioHandler> init() async {
    if (_instance != null && _isInitialized) {
      return _instance!;
    }

    if (_instance == null) {
      _instance = BibiAudioHandler._();
    }

    if (!_isInitialized) {
      try {
        await AudioService.init(
          builder: () => _instance!,
          config:  AudioServiceConfig(
            androidNotificationChannelId: 'com.example.bibi.audio',
            androidNotificationChannelName: 'BIBI Audio',
            androidNotificationOngoing: true,
            androidStopForegroundOnPause: true,
            notificationColor: Color(0xFFFFF4F4),
          ),
        );
        _isInitialized = true;
        if (kDebugMode) {
          print('✅ AudioService initialized');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ AudioService init failed: $e');
        }
        rethrow;
      }
    }

    return _instance!;
  }

  /// Get the singleton instance. Returns null if not initialized.
  /// Always check for null before using!
  static BibiAudioHandler? get instance => _instance;

  /// Check if the audio handler is ready to use
  static bool get isReady => _instance != null && _isInitialized;

  // ── Internal player ────────────────────────────────────────────────────────

  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  // ── Load & play ────────────────────────────────────────────────────────────

  /// Load an asset [assetPath] and start playback, updating the media notification
  /// with [title] and optional [artist].
  Future<void> loadAndPlay({
    required String assetPath,
    required String title,
    String artist = 'BIBI',
  }) async {
    try {
      // Build a MediaItem so the notification shows title + artist.
      mediaItem.add(MediaItem(
        id: assetPath,
        title: title,
        artist: artist,
        // artUri can be added here if you have a cover image asset.
      ));

      await _player.setAsset(assetPath);
      final dur = _player.duration;
      if (dur != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: dur));
      }
      await _player.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audio: $e');
      }
      rethrow;
    }
  }

  // ── BaseAudioHandler overrides (called by OS / notification buttons) ───────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {} // no playlist, no-op

  @override
  Future<void> skipToPrevious() async {} // no playlist, no-op

  // ── Playback state stream → notification ──────────────────────────────────

  /// Call this once after init() to wire the player's streams into the
  /// [playbackState] broadcast that audio_service uses to update the
  /// notification buttons.
  void listenToPlayerState() {
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.rewind,
          MediaAction.fastForward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ));
    });

    // Also update duration whenever the media item changes.
    _player.durationStream.listen((dur) {
      if (dur != null && mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: dur));
      }
    });
  }

  /// Dispose the audio player (call when app is closing)
  void dispose() {
    _player.dispose();
  }
}