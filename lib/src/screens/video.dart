import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:ncs_app/src/screens/home.dart';
// import 'package:ncs_app/app_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:volume_control/volume_control.dart';

@RoutePage()
class VideoPage extends StatefulWidget {
  final String videoId;
  final String forward;
  final String backVideoId;
  final String previousVideoId;
  final String nextVideoId;
  final List<dynamic> videos;
  final String title;
  final String thumbnailUrl;
  final String playlistName;

  const VideoPage({required this.videoId,super.key,required this.forward,required this.backVideoId,required this.previousVideoId,required this.nextVideoId,required this.videos,required this.title,required this.thumbnailUrl, required this.playlistName,});

  @override
  // ignore: library_private_types_in_public_api
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late YoutubePlayerController _controller;//変数に代入
  late YoutubeMetaData _videoMetaData; //変数に代入
  late String nowVideoId;//変数に代入　初期値のvideoidを入れるために作った
  late String next;//変数に代入 初期値のvideoidを入れるために作った
  late String previous;//変数に代入　初期値のvideoidを入れるために作った
  bool playVideo = true; //trueにすることによって再生ボタンのままになる⏸️
  bool isMuted = false; //これもそうtrueにするとミュートマークになる🔇
  bool isRepeating = false; //これもそうw trueにするとリピートマークが最初から色がついている
  double _val = 0.0;
  Timer? timer;

  @override
  void initState() { // 必ず最初の一回は呼ばれる
    super.initState();
    initVolumeState();
    setState(() {
      nowVideoId = widget.videoId; // 最初に選択したvideoidをnowVideoId変数に入れている
      next = widget.nextVideoId; // 初期値として次の動画に行くための値を入れているchangeVideoIdメソッドから次の動画に行ったタイミングで2個次の動画があったら取ってきている
      previous = widget.previousVideoId; // これも同じ
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

  void listener() {
    if (_controller.value.isReady) { // もしYouTubeの動画再生の準備ができたら以下の処理を行なっている
      setState(() { // 画面の更新などをする
        _videoMetaData = _controller.metadata; // 動画の準備ができたらタイトルやチャンネル名やvideoIdなどを表示する
      });
    }
  }

  void changeVideoId() {
    setState(() { // 画面の更新などをする
      int currentIndex = widget.videos.indexWhere((videos) => videos['id']['videoId'] == nowVideoId); //　このコードは今再生されている動画のindexを取得している
      if (currentIndex >= 0 && currentIndex < widget.videos.length - 1) { // 今再生されている動画のindexが0以上(0も含める)だったらなのと最後の動画のindexより小さかった場合は以下の処理が動く
        nowVideoId = widget.videos[currentIndex + 1]['id']['videoId']; // currentIndex + 1 とすることによって次の動画を再生できる
        next = currentIndex + 2 < widget.videos.length ? widget.videos[currentIndex + 2]['id']['videoId'] : ''; // 今再生されている動画の次の次の動画を取得しているただし次の次の動画がないと空の文字列になる(正直矢印を無効にする処理を消したからいらないかもw)
      }
    });
    if (nowVideoId.isNotEmpty) { //　nowVideoIdが空でない場合以下の処理が動く
      _controller.load(nowVideoId);//　videoIdをロードして動画を再生している
    }
  }

  void backtoVideoId() {
    setState(() {
      int currentIndex = widget.videos.indexWhere((videos) => videos['id']['videoId'] == nowVideoId);//　このコードは今再生されている動画のindexを取得している
      if (currentIndex > 0) { //今再生されている動画のindexが0より(0は含めない)大きかったら
        nowVideoId = widget.videos[currentIndex - 1]['id']['videoId']; // currentIndex - 1とすることで前の動画に戻る
        previous = currentIndex - 2 >= 0 ? widget.videos[currentIndex - 2]['id']['videoId'] : ''; // 
      }
    });
    if (nowVideoId.isNotEmpty) { //　nowVideoIdが空でない場合以下の処理が動く
      _controller.load(nowVideoId); //　videoIdをロードして動画を再生している
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Youtube再生ページから離れるときにcontrollerが破棄されるようにする
    super.dispose();
  }

  void showLibrarySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ライブラリを選択'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300.0,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('playlistNames').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('データの取得中にエラーが発生しました'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final playlists = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index].data() as Map<String, dynamic>;
                    final playlistName = playlist['name'];

                    return ListTile(
                      title: Text(playlistName),
                      onTap: () {
                        addToLibrary(playlistName);
                        Navigator.pop(context); // リストアイテムをタップしたらダイアログを閉じる
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void addToLibrary(String libraryName) { // ライブラリに追加したデータたち以下
    final videoData = {
      'videoId': nowVideoId,
      'title': widget.title,
      'thumbnail': widget.thumbnailUrl,
      'videosList': widget.videos,
      'nextVideoId': widget.nextVideoId,
      'previousVideoId': widget.previousVideoId,
    };

    FirebaseFirestore.instance // ファイヤーベース内にライブラリとライブラリに入れた動画を保存エラーの処理もある
        .collection('libraries')
        .doc(libraryName) // 追加とは別の意味になる
        .collection('videos')
        .add(videoData) // 動画の情報を追加している
        .then((value) {
      print('動画がライブラリに追加されました');
    }).catchError((error) {
      print('動画の追加中にエラーが発生しました：$error');
    });
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

  @override
  Widget build(BuildContext context) {

    IconButton iconButtonforward = IconButton(
      onPressed: () {
        changeVideoId();
      },
      icon: const Icon(Icons.skip_next),
    );

    IconButton iconButtonBack = IconButton(
      onPressed: () {
        backtoVideoId();
      },
      icon: const Icon(Icons.skip_previous),
    );

    IconButton iconButtonAdd = IconButton(
      onPressed: () {
        showLibrarySelectionDialog();
      },
      icon: const Icon(Icons.library_add),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Play Video',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed:() {
            context.router.pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Column(
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
                changeVideoId();
              }
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              playvideoButton(),
              const Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Author: ${_videoMetaData.author}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
              Text(
                "Title: ${_videoMetaData.title}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              // Text(
              //   "Video ID: ${_videoMetaData.videoId}",
              //     style: const TextStyle(
              //       fontSize: 17,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // const Padding(padding: EdgeInsets.all(10)),
            ],
          ),
          Center(
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.all(15)),
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
              iconButtonBack,
              muteButton(),
              repeatButton(),
              iconButtonforward,
              iconButtonAdd,
            ],
          ),
          const Padding(padding: EdgeInsets.all(10)),
        ],
      ),
    );
  }
}