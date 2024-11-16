import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  const VideoPage({super.key, 
    required this.videoId,
    required this.forward,
    required this.backVideoId,
    required this.previousVideoId,
    required this.nextVideoId,
    required this.videos,
    required this.title,
    required this.thumbnailUrl,
    required this.playlistName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late YoutubePlayerController _controller;
  late YoutubeMetaData _videoMetaData;
  late String nowVideoId;
  late String next;
  late String previous;
  bool playVideo = true;
  bool isMuted = false;
  bool isRepeating = false;
  double _val = 0.5;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initVolumeState();
    setState(() {
      nowVideoId = widget.videoId;
      next = widget.nextVideoId;
      previous = widget.previousVideoId;
      _videoMetaData = const YoutubeMetaData();
      setYouTube();
    });
  }

  Future<void> initVolumeState() async {
    if (!mounted) return;
    _val = await VolumeControl.volume;
    setState(() {});
  }

  void setYouTube() {
    setState(() {
      _controller = YoutubePlayerController(
        initialVideoId: nowVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          hideControls: false,
          controlsVisibleAtStart: true,
          enableCaption: true,
          captionLanguage: 'en',
          forceHD: true,
        ),
      );
      _controller.addListener(listener);
    });
  }

  void onRepeatIconPressed() {
    setState(() {
      isMuted = !isMuted;
      isMuted ? _controller.mute() : _controller.unMute();
    });
  }

  void onPressedIconVideo() {
    setState(() {
      playVideo ? _controller.pause() : _controller.play();
      playVideo = !playVideo;
    });
  }

  void toggleRepeat() {
    setState(() {
      isRepeating = !isRepeating;
    });
  }

  void listener() {
    if (_controller.value.isReady) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }
  }

  void changeVideoId() {
    setState(() {
      int currentIndex =
          widget.videos.indexWhere((videos) => videos['id']['videoId'] == nowVideoId);
      if (currentIndex >= 0 && currentIndex < widget.videos.length - 1) {
        nowVideoId = widget.videos[currentIndex + 1]['id']['videoId'];
        next = currentIndex + 2 < widget.videos.length
            ? widget.videos[currentIndex + 2]['id']['videoId']
            : '';
      }
    });
    if (nowVideoId.isNotEmpty) {
      _controller.load(nowVideoId);
    }
  }

  void backtoVideoId() {
    setState(() {
      int currentIndex =
          widget.videos.indexWhere((videos) => videos['id']['videoId'] == nowVideoId);
      if (currentIndex > 0) {
        nowVideoId = widget.videos[currentIndex - 1]['id']['videoId'];
        previous = currentIndex - 2 >= 0 ? widget.videos[currentIndex - 2]['id']['videoId'] : '';
      }
    });
    if (nowVideoId.isNotEmpty) {
      _controller.load(nowVideoId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
                        Navigator.pop(context);
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

  void addToLibrary(String libraryName) {
    final videoData = {
      'videoId': nowVideoId,
      'title': widget.title,
      'thumbnail': widget.thumbnailUrl,
      'videosList': widget.videos,
      'nextVideoId': widget.nextVideoId,
      'previousVideoId': widget.previousVideoId,
    };

    FirebaseFirestore.instance
        .collection('libraries')
        .doc(libraryName)
        .collection('videos')
        .add(videoData)
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

  // IconButton playvideoButton() {
  //   return IconButton(
  //     icon: playVideo ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
  //     onPressed: onPressedIconVideo,
  //   );
  // }

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
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed:() {
            Navigator.pop(context);
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
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Text(
                "Video ID: ${_videoMetaData.videoId}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const Padding(padding: EdgeInsets.all(10)),
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