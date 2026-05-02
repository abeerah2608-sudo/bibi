import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../bloc/bloc_exports.dart';
import '../services/remote_asset_service.dart';

/// A minimal audio player widget for onboarding screens
class OnboardingAudioPlayer extends StatefulWidget {
  final String englishAudioPath;
  final String urduAudioPath;
  final double height;

  const OnboardingAudioPlayer({
    super.key,
    required this.englishAudioPath,
    required this.urduAudioPath,
    this.height = 50,
  });

  @override
  State<OnboardingAudioPlayer> createState() => _OnboardingAudioPlayerState();
}

class _OnboardingAudioPlayerState extends State<OnboardingAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  String _currentLanguage = 'English';
  String _loadedAudioPath = '';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadedAudioPath = widget.englishAudioPath;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudio(String path) async {
    if (_loadedAudioPath != path) {
      await _audioPlayer.stop();
      
      // Support both Firebase gs:// URLs and local assets
      if (RemoteAssetService.isRemoteUrl(path)) {
        final httpsUrl = RemoteAssetService.convertGsUrlToHttps(path);
        await _audioPlayer.setUrl(httpsUrl);
        debugPrint('🔊 Loading audio from Firebase: $path');
      } else {
        await _audioPlayer.setAsset(path);
        debugPrint('🔊 Loading audio from local assets: $path');
      }
      
      _loadedAudioPath = path;
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final audioPath =
            _currentLanguage == 'English' ? widget.englishAudioPath : widget.urduAudioPath;
        await _loadAudio(audioPath);
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (state is LanguageSelected) {
          setState(() {
            _currentLanguage = state.language;
          });
          // Stop current audio when language changes
          if (_isPlaying) {
            _audioPlayer.stop();
            setState(() => _isPlaying = false);
          }
        }
      },
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF68AA8).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF68AA8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing ?? false;

                  if (playing != _isPlaying) {
                    Future.microtask(() {
                      setState(() => _isPlaying = playing);
                    });
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentLanguage,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        processingState == ProcessingState.loading
                            ? 'Loading...'
                            : playing
                                ? 'Playing...'
                                : 'Tap to listen',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B5E3C),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
