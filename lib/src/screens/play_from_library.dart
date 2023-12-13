// ignore_for_file: camel_case_types
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/src/screens/details_page.dart';
import 'package:volume_control/volume_control.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LibraryVideoPage extends StatefulWidget {
  final String videoId;
  final String playlistName;


  const LibraryVideoPage({super.key, required this.videoId, required this.playlistName});

  @override
  State<LibraryVideoPage> createState() => _LibraryVideoPageState();
}

class _LibraryVideoPageState extends State<LibraryVideoPage> {
  late YoutubePlayerController _controller;//変数に代入
  late YoutubeMetaData _videoMetaData; //変数に代入
  late String next;//変数に代入 初期値のvideoidを入れるために作った
  late String previous;//変数に代入　初期値のvideoidを入れるために作った
  late String nowVideoId;//変数に代入　初期値のvideoidを入れるために作った
  bool playVideo = true; //trueにすることによって再生ボタンのままになる⏸️
  bool isMuted = false; //これもそうtrueにするとミュートマークになる🔇
  bool isRepeating = false; //これもそうw trueにするとリピートマークが最初から色がついている
  double _val = 0.0;
  Timer? timer;

  @override
  void initState() { // 必ず最初の一回は呼ばれる
    super.initState();
    setState(() {
      nowVideoId = widget.videoId; // 最初に選択したvideoidをnowVideoId変数に入れている
      _videoMetaData = const YoutubeMetaData(); // これは現在再生中のvideoidを表示したりこの動画のチャンネル名やタイトルなどを表示できるウィジェットを_videoMetaDataに格納している
      setYouTube(); //これは必ず初期化するんだなという考え方でいい
    });
  }

  Future<void> initVolumeState() async {
    if (!mounted) return;

    // 現在の音量を読み取る
    _val = await VolumeControl.volume;
    setState(() {});
  }

  void setYouTube() { // YouTubeの動画をコントロール(設定)するためのメソッド
    setState(() { // 画面の更新などをする
      _controller = YoutubePlayerController(
        initialVideoId: nowVideoId, // YoutubePlayerControllerを使ったら必ず必要な項目。初期値として最初にタップした動画のvideoIdが渡される
        flags: const YoutubePlayerFlags( // 動画の画質とか制御とかの設定
          autoPlay: true,
          hideControls: false,
          controlsVisibleAtStart: true,
          enableCaption: true,
          captionLanguage: 'en',
          forceHD: true,
        ),
      );
      _controller.addListener(listener); // 動画の再生状態が変更されたり、再生位置が変更されたりするたびに呼び出されるメソッド
    });
  }

  void listener() {
    if (_controller.value.isReady) { // もしYouTubeの動画再生の準備ができたら以下の処理を行なっている
      setState(() { // 画面の更新などをする
        _videoMetaData = _controller.metadata; // 動画の準備ができたらタイトルやチャンネル名やvideoIdなどを表示する
      });
    }
  }

  void onRepeatIconPressed() {
    setState(() { // 画面の更新などをする
      isMuted = !isMuted; // デフォルトはfalseなのでミュートマークにはなっていないから!マークで反転させてる(trueにしている)
      isMuted ? _controller.mute() : _controller.unMute(); // ここでfalseだったらとtrueだったらの条件を指定している
    });
  }

  void onPressedIconVideo() {
    setState(() { // 画面の更新などをする
      playVideo ? _controller.pause() : _controller.play(); // ここでfalseだったらとtrueだったらの条件を指定している
      playVideo = !playVideo; // デフォルトはfalseなので⏸️マークになっているので!マークで反転させてる(trueにしている)
    });
  }

  void toggleRepeat() {
    setState(() { // 画面の更新などをする
      isRepeating = !isRepeating; // デフォルトはfalseなので🔁マークが光っていない状態になっているので!マークで反転させてる(trueにしている)
    });
  }

  void changeVideoId(List<QueryDocumentSnapshot<Object?>> videos) {
    setState(() {
      int currentIndex = videos.indexWhere((video) => video['videoId'] == nowVideoId);
      if (currentIndex >= 0 && currentIndex < videos.length - 1) {
        nowVideoId = videos[currentIndex + 1]['videoId'];
        next = currentIndex + 2 < videos.length ? videos[currentIndex + 2]['videoId'] : '';
      }
    });

    if (nowVideoId.isNotEmpty) {
      _controller.load(nowVideoId);
    }
  }

  void backtoVideoId(List<QueryDocumentSnapshot<Object?>> videos) {
    setState(() {
      int currentIndex = videos.indexWhere((video) => video['videoId'] == nowVideoId);
      if (currentIndex > 0) {
        nowVideoId = videos[currentIndex - 1]['videoId'];
        previous = currentIndex - 2 >= 0 ? videos[currentIndex - 2]['videoId'] : '';
      }
    });

    if (nowVideoId.isNotEmpty) {
      _controller.load(nowVideoId);
    }
  }

  void onTapVideo(dynamic videoId) {
    setState(() {
      nowVideoId = videoId;
    });

    if (nowVideoId.isNotEmpty) {
      _controller.load(nowVideoId);
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Youtube再生ページから離れるときにcontrollerが破棄されるようにする
    super.dispose();
  }

  IconButton muteButton() {
    return IconButton(
      icon: isMuted ? const Icon(Icons.volume_off) : const Icon(Icons.volume_up),
      onPressed: onRepeatIconPressed,
    );
  }

  IconButton playvideoButton() {
    return IconButton(
      icon: playVideo ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      onPressed: onPressedIconVideo,
    );
  }

  IconButton repeatButton() {
    return IconButton(
      icon: isRepeating ? const Icon(Icons.repeat, color: Colors.amber) : const Icon(Icons.repeat),
      onPressed: toggleRepeat,
    );
  }

  IconButton iconButtonforward(List<QueryDocumentSnapshot<Object?>> videos) {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: () {
        changeVideoId(videos);
      },
    );
  }

  IconButton iconButtonBack(List<QueryDocumentSnapshot<Object?>> videos) {
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: () {
        backtoVideoId(videos);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Play from Library',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(
            Icons.library_books,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, DetailsPage(playlistName: widget.playlistName, playlistId: ''));
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('libraries')
          .doc(widget.playlistName)
          .collection('videos')
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('データの取得中にエラーが発生しました'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final videos = snapshot.data!.docs;

          if (videos.isEmpty) {
            return const Center(child: Text('動画が見つかりませんでした'));
          }

          return Column(
            children: [
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: false,
                progressIndicatorColor: Colors.amber,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.amber,
                  handleColor: Colors.amberAccent,
                ),
                onReady: () {
                  _videoMetaData = _controller.metadata;
                },
                onEnded: (_) {
                  if (isRepeating) {
                    _controller.seekTo(const Duration(seconds: 0));
                    _controller.play();
                  } else {
                    changeVideoId(videos);
                  }
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  playvideoButton(),
                  Text(
                    "Author: ${_videoMetaData.author}",
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Text(
                    "Title: ${_videoMetaData.title}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  // Text(
                  //   "Video ID: ${_videoMetaData.videoId}",
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const Padding(padding: EdgeInsets.all(5)),
                ],
              ),
              Center(
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(10)),
                    const Text(
                      "Volume:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _val,
                      min: 0,
                      max: 1,
                      divisions: 100,
                      onChanged: (val) {
                        _val = val;
                        setState(() {});
                        if (timer != null) {
                          timer?.cancel();
                        }

                        // スムーズなスライディングのためにタイマーを使用
                        timer = Timer(const Duration(milliseconds: 200), () {
                          VolumeControl.setVolume(val);
                        });

                        print("val: $val");
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconButtonBack(videos),
                  muteButton(),
                  repeatButton(),
                  iconButtonforward(videos),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index].data() as Map<String, dynamic>;
                    final videoName = video['title'];
                    final videoThumbnail = video['thumbnail'];
                    final videoId = video['videoId'];

                    return ListTile(
                      title: Text(videoName),
                      leading: Image.network(videoThumbnail),
                      onTap: () {
                        onTapVideo(videoId);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}