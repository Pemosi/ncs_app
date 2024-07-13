import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/src/screens/bacground/audio_handler.dart';
import 'package:ncs_app/src/screens/bacground/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class BackgroundAudioScreenState extends ChangeNotifier {
  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  AudioState audioState = AudioState.paused;
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _progressBarSubscription;
  MediaItem? _currentMediaItem;  // 現在再生中の曲

  final AudioServiceHandler _handler = getIt<AudioServiceHandler>();

  List<MediaItem> get playlist => _playlist;

  static final List<MediaItem> _playlist = [
    MediaItem(
      id: 'assets/bgm/西表島.mp3',
      album: "にゃんこBGM",
      title: "にゃんこ西表島",
      artist: "PONOS",
      artUri: Uri.parse('https://games.app-liv.jp/images/articles/2016/06/gd138472_-13.jpg'),
    ),
    MediaItem(
      id: 'assets/bgm/アポロ決戦.mp3',
      album: "にゃんこBGM",
      title: "アポロ決戦",
      artist: "PONOS",
      artUri: Uri.parse('https://games.app-liv.jp/images/articles/2016/09/gd183522_-13.jpg'),
    ),
    MediaItem(
      id: 'assets/bgm/ビックバン組曲.mp3',
      album: "にゃんこBGM",
      title: "ビッグバン",
      artist: "PONOS",
      artUri: Uri.parse('https://image02.seesaawiki.jp/b/i/battlecatswiki/F5cvA0LXky.PNG'),
    ),
    MediaItem(
      id: 'assets/bgm/スターフィリバスター.mp3',
      album: "にゃんこBGM",
      title: "宇宙の危機！スターフィリバスター",
      artist: "PONOS",
      artUri: Uri.parse('https://image02.seesaawiki.jp/b/i/battlecatswiki/ef44967993c6f9df.png'),
    ),
    MediaItem(
      id: 'assets/bgm/消滅都市.mp3',
      album: "にゃんこBGM",
      title: "消滅都市 X にゃんこ大戦争コラボ",
      artist: "PONOS",
      artUri: Uri.parse('https://i.ytimg.com/vi/JYirsfGB19Q/hqdefault.jpg?sqp=-oaymwEcCOADEI4CSFXyq4qpAw4IARUAAIhCGAFwAcABBg==&rs=AOn4CLD-52sOYg1-atvrrLNnV0kjvZJlnA'),
    ),
  ];

  void init() {
    _handler.initPlayer(_playlist);
    _listenToPlaybackState();
    _listenForProgressBarState();
  }

  void _listenToPlaybackState() {
    _playbackSubscription =
        _handler.playbackState.listen((PlaybackState state) {
      debugPrint('current state:${state.processingState}');
      debugPrint('playing:${state.playing}');
      _currentMediaItem = _handler.mediaItem.value;
      notifyListeners();  // 再生中の曲が変わった時にUIを更新する

      if (isLoadingState(state)) {
        setAudioState(AudioState.loading);
      } else if (isAudioReady(state)) {
        setAudioState(AudioState.ready);
      } else if (isAudioPlaying(state)) {
        setAudioState(AudioState.playing);
      } else if (isAudioPaused(state)) {
        setAudioState(AudioState.paused);
      } else if (hasCompleted(state)) {
        setAudioState(AudioState.paused);
      }
    });
  }

  void _listenForProgressBarState() {
    _progressBarSubscription = CombineLatestStream.combine3(
      AudioService.position,
      _handler.playbackState,
      _handler.mediaItem,
      (Duration current, PlaybackState state, MediaItem? mediaItem) =>
      ProgressBarState(
        current: current,
        buffered: state.bufferedPosition,
        total: mediaItem?.duration ?? Duration.zero,
      ),
    ).listen((ProgressBarState state) => setProgressBarState(state));
  }

  bool isLoadingState(PlaybackState state) {
    return state.processingState == AudioProcessingState.loading ||
        state.processingState == AudioProcessingState.buffering;
  }

  bool isAudioReady(PlaybackState state) {
    return state.processingState == AudioProcessingState.ready &&
        !state.playing;
  }

  bool isAudioPlaying(PlaybackState state) {
    return state.playing && !hasCompleted(state);
  }

  bool isAudioPaused(PlaybackState state) {
    return !state.playing && !isLoadingState(state);
  }

  bool hasCompleted(PlaybackState state) {
    return state.processingState == AudioProcessingState.completed;
  }

  @override
  void dispose() {
    _handler.stop();
    _playbackSubscription.cancel();
    _progressBarSubscription.cancel();
    super.dispose();
  }

  void setAudioState(AudioState state) {
    audioState = state;
    notifyListeners();
  }

  void setProgressBarState(ProgressBarState state) {
    progressBarState = state;
    notifyListeners();
  }

  void play() => _handler.play();

  void pause() => _handler.pause();

  void seek(Duration position) => _handler.seek(position);

  void stop() => _handler.stop();

  void playTrack(MediaItem item) {
    _handler.stop();  // 現在の再生を停止
    _handler.initPlayer([item]);  // 選択された曲を再生
    _handler.play();
  }

  void skipToNext() => _handler.skipToNext();

  void skipToPrevious() => _handler.skipToPrevious();

  MediaItem? getCurrentTrack() => _currentMediaItem;  // 現在再生中の曲を取得
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum AudioState {
  ready,
  paused,
  playing,
  loading,
}