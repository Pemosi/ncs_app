import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

Future<AudioServiceHandler> initeAudioService() async {
  return await AudioService.init(
      builder: () => AudioServiceHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mycompany.myapp.audio',
        androidNotificationChannelName: 'Test Audio Service',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ));
}

class AudioServiceHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  List<MediaItem> _playlist = [];
  int _currentIndex = 0;

  Future<void> initPlayer(List<MediaItem> playlist) async {
    try {
      _playlist = playlist;
      _currentIndex = 0;

      _notifyAudioHandlerAboutPlaybackEvents();
      await _setAndPlayCurrent();
    } catch (e) {
      debugPrint('ERROR OCCURRED: $e');
    }
  }

  Future<void> _setAndPlayCurrent() async {
    if (_playlist.isEmpty) return;
    MediaItem currentItem = _playlist[_currentIndex];
    Uri uri = await _loadAsset(currentItem.id);

    await _player.setAudioSource(AudioSource.uri(uri));
    mediaItem.add(currentItem.copyWith(duration: _player.duration));
    _player.play();
  }

  Future<Uri> _loadAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(data.buffer.asUint8List());
    return Uri.file(file.path);
  }

  /* --- SUBSCRIBE --- */
  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
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
        queueIndex: event.currentIndex,
      ));
    });
  }

  /* --- Audio Control --- */
  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await _setAndPlayCurrent();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _setAndPlayCurrent();
    }
  }
}