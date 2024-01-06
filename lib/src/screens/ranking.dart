import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/app_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@RoutePage()
class LankingRouterPage extends AutoRouter {
  const LankingRouterPage({super.key});
}

@RoutePage()
class LankingPage extends StatefulWidget {
  const LankingPage({Key? key}) : super(key: key);

  @override
  State<LankingPage> createState() => _LankingState();
}

class _LankingState extends State<LankingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<dynamic>> rankingVideosFuture;
  late User? _user; // ログインユーザー情報

  @override
  void initState() {
    super.initState();
    rankingVideosFuture = fetchRankingVideos();
    _user = FirebaseAuth.instance.currentUser; // 初期化時にログインユーザー情報を取得
  }

  Future<List<dynamic>> fetchRankingVideos() async {
    const String apiKey = 'AIzaSyCFMsc8U6804ORH2NO8HvGGgikpwvgZqLE'; // ご自身のYouTube Data APIキーを設定してください
    const String channelId = 'UC_aEa8K-EOJ3D6gOs7HcyNg'; // ランキングを取得するチャンネルのIDを設定してください
    const String apiUrl = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&maxResults=5&order=viewCount&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to fetch ranking videos');
    }
  }

  void _handleLoginLogout() async {
    if (_user == null) {
      // ログインしていない場合はログインページに遷移
      await AutoRouter.of(context).push(const LoginRoute());
    } else {
      // ログアウト処理
      await FirebaseAuth.instance.signOut();
      setState(() {
        _user = null;
      });
    }
  }

  // Widget buildRankingVideos(List<dynamic> videos) {
  //   return ListView.builder(
  //     physics: const AlwaysScrollableScrollPhysics(),
  //     itemCount: videos.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       final video = videos[index];
  //       final String videoId = video['id']['videoId'];
  //       final String title = video['snippet']['title'];
  //       final String thumbnailUrl = video['snippet']['thumbnails']['medium']['url'];
  //       final String backVideoId = index > 0 ? videos[index-1]['id']['videoId'] ?? '' : ''; //追加した
  //       final String forward = index < videos.length - 1 ? videos[index+1]['id']['videoId'] ?? '' : ''; //追加した
  //       final bool isFirstVideo = index == 0; // 現在のビデオがリストの先頭かどうかを判定
  //       final bool isLastVideo = index == videos.length - 1; // 現在のビデオがリストの最後かどうかを判定
  //       final String previousVideoId = isFirstVideo ? '' : videos[index - 1]['id']['videoId'] ?? '';
  //       final String nextVideoId = isLastVideo ? '' : videos[index + 1]['id']['videoId'] ?? '';

  //       return ListTile(
  //         leading: Image.network(thumbnailUrl),
  //         title: Text(title),
  //         onTap: () {
  //           context.router.push(
  //             VideoRoute(
  //               videoId: videoId,
  //               backVideoId: backVideoId,
  //               forward: forward,
  //               nextVideoId: nextVideoId,
  //               previousVideoId: previousVideoId,
  //               videos: videos, 
  //               thumbnailUrl: thumbnailUrl, 
  //               title: title,
  //               playlistName: '',
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: _user != null ? Text(_user!.displayName ?? '') : null,
              accountEmail: _user != null ? Text(_user!.email ?? '') : null,
              currentAccountPicture: _user != null? CircleAvatar(
                backgroundImage: NetworkImage(_user!.photoURL ?? ''),
              ) : null,
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(_user != null ? "ログアウト" : "ログイン"), // ログイン状態によってボタンの表示を変更
              onTap: _handleLoginLogout,
            ),
            // ListTile(
            //   leading: const Icon(Icons.home),
            //   title: const Text("Home"),
            //   onTap: () {
            //     // Handle home tap
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: const Text("Settings"),
            //   onTap: () {
            //     // Handle settings tap
            //   },
            // ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'ランキング👑',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(
            Icons.account_circle,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: rankingVideosFuture,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to fetch ranking videos'));
          } else {
            final List<dynamic> videos = snapshot.data!;
            return Center(
              child: ListView.builder(
                itemCount: videos.length,
                itemBuilder: (BuildContext context, int index) {
                  final video = videos[index];
                  final String videoId = video['id']['videoId'];
                  final String title = video['snippet']['title'];
                  final String thumbnailUrl = video['snippet']['thumbnails']['medium']['url'];
                  final String backVideoId = index > 0 ? videos[index-1]['id']['videoId'] ?? '' : ''; //追加した
                  final String forward = index < videos.length - 1 ? videos[index+1]['id']['videoId'] ?? '' : ''; //追加した
                  final bool isFirstVideo = index == 0; // 現在のビデオがリストの先頭かどうかを判定
                  final bool isLastVideo = index == videos.length - 1; // 現在のビデオがリストの最後かどうかを判定
                  final String previousVideoId = isFirstVideo ? '' : videos[index - 1]['id']['videoId'] ?? '';
                  final String nextVideoId = isLastVideo ? '' : videos[index + 1]['id']['videoId'] ?? '';



                  return GestureDetector(
                    onTap: () {
                      context.router.push(
                        VideoRoute(
                          videoId: videoId,
                          backVideoId: backVideoId,
                          forward: forward,
                          nextVideoId: nextVideoId,
                          previousVideoId: previousVideoId,
                          videos: videos, 
                          thumbnailUrl: thumbnailUrl, 
                          title: title,
                          playlistName: '',
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Image.network(thumbnailUrl),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(title),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}