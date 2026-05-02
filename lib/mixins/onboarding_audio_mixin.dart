import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/remote_asset_service.dart';

class _OnboardingAudioLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      final player = OnboardingAudioMixin.activePlayer;
      if (player != null) {
        player.stop();
        debugPrint('⏹️ Global onboarding audio stopped on app lifecycle: $state');
      }
    }
  }
}

mixin OnboardingAudioMixin<T extends StatefulWidget> on State<T> {
  static AudioPlayer? _activePlayer;
  static int? _activeOwnerId;
  static bool _lifecycleObserverRegistered = false;
  static final _OnboardingAudioLifecycleObserver _lifecycleObserver =
      _OnboardingAudioLifecycleObserver();

  static AudioPlayer? get activePlayer => _activePlayer;

  AudioPlayer? _audioPlayer;
  String _currentLanguage = 'English';
  String _loadedAudioPath = '';
  int _loadToken = 0;
  bool _isDisposed = false;
  final int _ownerId = identityHashCode(Object());

  String get englishAudioPath;
  String get urduAudioPath;

  String get currentAudioPath {
      // Play Urdu audio if language is Urdu or Roman Urdu
      if (_currentLanguage == 'اردو' || _currentLanguage == 'Roman Urdu') {
        return urduAudioPath;
      }
      // Otherwise, default to English
      return englishAudioPath;
    }

    Future<void> _ensureLifecycleObserver() async {
      if (_lifecycleObserverRegistered) return;
      WidgetsBinding.instance.addObserver(_lifecycleObserver);
      _lifecycleObserverRegistered = true;
    }

    Future<void> initAudio([String initialLanguage = 'English']) async {
      await _ensureLifecycleObserver();

      _isDisposed = false;
      _currentLanguage = initialLanguage;

      _audioPlayer ??= AudioPlayer();

      // Ensure only one onboarding audio source is active at a time.
      if (_activePlayer != null && _activePlayer != _audioPlayer) {
        try {
          await _activePlayer!.stop();
        } catch (_) {}
      }
      _activePlayer = _audioPlayer;
      _activeOwnerId = _ownerId;

      final path = currentAudioPath;
      if (path.isNotEmpty) {
        _loadAudio(path);
      }
    }

  void _loadAudio(String path) {
      if (path.isEmpty) return;
      final token = ++_loadToken;

    Future<void>(() async {
        if (_isDisposed || token != _loadToken || _activeOwnerId != _ownerId) {
          return;
        }

      final audioPath = await RemoteAssetService.resolveDownloadUrl(path);
      debugPrint('🎵 Resolved audio URL: $path → $audioPath');

      try {
          final player = _audioPlayer;
          if (player == null || _isDisposed || token != _loadToken || _activeOwnerId != _ownerId) {
            return;
          }

        // Try to use a cached local file when available
        final cached = await RemoteAssetService().getCachedAssetPath(audioPath);
          if (_isDisposed || token != _loadToken || _activeOwnerId != _ownerId) {
            return;
          }

        if (cached != null && cached.isNotEmpty && !cached.startsWith('http')) {
          debugPrint('🎧 Playing from cache: $cached');
            await player.setFilePath(cached);
        } else {
          debugPrint('🎧 Playing from network source: $audioPath');
            await player.setUrl(audioPath);
        }

          if (_isDisposed || token != _loadToken || _activeOwnerId != _ownerId) {
            return;
          }

          await player.play();
        _loadedAudioPath = path;
        debugPrint('✅ Audio loaded and playing');
      } catch (e) {
        debugPrint('❌ Audio load error for path=$path resolved=$audioPath: $e');

        try {
          final player = _audioPlayer;
          if (player == null || _isDisposed || token != _loadToken || _activeOwnerId != _ownerId) {
            return;
          }

          final fallbackCached = await RemoteAssetService().getCachedAssetPath(audioPath);
          if (fallbackCached != null && fallbackCached.isNotEmpty && !fallbackCached.startsWith('http')) {
            debugPrint('🔁 Retrying audio from cached file: $fallbackCached');
            await player.setFilePath(fallbackCached);
            if (_isDisposed || token != _loadToken || _activeOwnerId != _ownerId) {
              return;
            }
            await player.play();
            _loadedAudioPath = path;
            debugPrint('✅ Audio recovered from cache');
          }
        } catch (fallbackError) {
          debugPrint('❌ Audio cache fallback failed for path=$path: $fallbackError');
        }
      }
    });
  }

  void onLanguageChanged(String newLanguage) {
    if (_audioPlayer == null) return;
    if (newLanguage == _currentLanguage) return;

    _currentLanguage = newLanguage;
    final newPath = currentAudioPath;

    if (newPath != _loadedAudioPath) {
      _audioPlayer!.stop();
      _loadAudio(newPath);
    }
  }

  void stopAudio() {
    _audioPlayer?.stop();
  }

  @override
  Future<void> disposeAudio() async {
    _isDisposed = true;
    _loadToken++;

    final player = _audioPlayer;
    if (player == null) return;

    try {
      await player.stop();
    } catch (_) {}

    if (_activePlayer == player && _activeOwnerId == _ownerId) {
      _activePlayer = null;
      _activeOwnerId = null;
    }

    await player.dispose();
    _audioPlayer = null;
  }
}