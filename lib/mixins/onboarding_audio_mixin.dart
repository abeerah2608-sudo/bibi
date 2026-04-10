import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

mixin OnboardingAudioMixin<T extends StatefulWidget> on State<T> {
  AudioPlayer? _audioPlayer;
  String _currentLanguage = 'English';
  String _loadedAudioPath = '';

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

 void initAudio([String initialLanguage = 'English']) {
  _audioPlayer = AudioPlayer();
  _currentLanguage = initialLanguage;
  _loadAudio(currentAudioPath);
}

  void _loadAudio(String path) {
    _audioPlayer?.setAsset(path).then((_) {
      _audioPlayer?.play();
      _loadedAudioPath = path;
    }).catchError((e) {
      debugPrint('Audio load error: $e');
    });
  }

  void onLanguageChanged(String newLanguage) {
    if (_audioPlayer == null) return;
    if (newLanguage == _currentLanguage) return;

    _currentLanguage = newLanguage;
    final newPath = currentAudioPath;

    if (newPath != _loadedAudioPath) {
      final wasPlaying = _audioPlayer!.playing;
      _audioPlayer!.stop();
      _loadAudio(newPath);
      if (wasPlaying) _audioPlayer!.play();
    }
  }

  void stopAudio() => _audioPlayer?.stop();

  @override
  void disposeAudio() {
    _audioPlayer?.dispose();
  }
}