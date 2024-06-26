import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';


bool _isInitialized = false;

Future<AudioServiceHandler?> initeAudioService() async {
  if (!_isInitialized) {
    _isInitialized = true;
    return await AudioService.init(
        builder: () => AudioServiceHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.mycompany.myapp.audio',
          androidNotificationChannelName: 'Test Audio Service',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ));
  } else {
    // 既に初期化済みの場合は何もしないか、適切な処理を行う
    // この場合、適切なエラーハンドリングやログ出力を行うのが良いでしょう
    return null;
  }
}

class AudioServiceHandler extends BaseAudioHandler {
  final AudioPlayer player = AudioPlayer();
  AudioPlayer? subPlayer1;
  AudioPlayer? subPlayer2;

  Future<void> initPlayer(MediaItem item) async {
    try {
      _notifyAudioHandlerAboutPlaybackEvents();
      await player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));
      mediaItem.add(item.copyWith(duration: player.duration));
    } catch (e) {
      debugPrint('ERROR OCCURED:$e');
    }
  }

  /* --- SUBSCRIBE --- */
  void _notifyAudioHandlerAboutPlaybackEvents() {
    player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = player.playing;
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
        }[player.processingState]!,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  /* --- Audio Control --- */
  @override
  Future<void> play() async {
    player.play();
    subPlayer1?.play();
    subPlayer2?.play();
  }

  @override
  Future<void> pause() async {
    player.pause();
    subPlayer1?.pause();
    subPlayer2?.pause();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() {
    player.stop();
    return super.stop();
  }

  void dispose() {
    subPlayer1?.dispose();
    subPlayer2?.dispose();
  }

/* --- SUB AUDIO CONTROL --- */

  Future<void> setAudioSource1(MediaItem item) async {
    subPlayer1 = AudioPlayer()
      ..setAudioSource(AudioSource.uri(Uri.parse(item.id)))
      ..setLoopMode(LoopMode.one)
      ..play();
  }

  Future<void> setAudioSource2(MediaItem item) async {
    subPlayer2 = AudioPlayer()
      ..setAudioSource(AudioSource.uri(Uri.parse(item.id)))
      ..setLoopMode(LoopMode.one)
      ..play();
  }

  void setVolume1(double value) {
    subPlayer1?.setVolume(value);
  }

  void setVolume2(double value) {
    subPlayer2?.setVolume(value);
  }

  /* --- Volume Control --- */

  void setVolume(double volume) {
    player.setVolume(volume);
  }
}