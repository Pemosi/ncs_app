import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/app_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

@RoutePage()
class HomeRouterPage extends AutoRouter {
  const HomeRouterPage({super.key});
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<dynamic>> recommendedVideosFuture;
  User? _user; // ログインユーザー情報

  @override
  void initState() {
    super.initState();
    recommendedVideosFuture = fetchRecommendedVideos();
    // ログイン状態の変更を監視し、ログイン状態が変更されたらsetState()を呼び出してUIを更新する
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<List<dynamic>> fetchRecommendedVideos() async {
    const String apiKey = 'AIzaSyCFMsc8U6804ORH2NO8HvGGgikpwvgZqLE'; //YouTubeAPI Key
    const String channelId = 'UC_aEa8K-EOJ3D6gOs7HcyNg'; //チャンネルID
    const String apiUrl = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&maxResults=5&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to fetch recommended videos');
    }
  }

  void _handleLoginLogout() async {
    if (_user == null) {
      Navigator.pop(context);
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

  // Widget buildRecommendedVideos(List<dynamic> videos) {
  //   return ListView.builder(
  //     physics: const AlwaysScrollableScrollPhysics(),
  //     itemCount: videos.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       final video = videos[index];
  //       final String videoId = video['id']['videoId'];
  //       final String title = video['snippet']['title'];
  //       final String thumbnailUrl = video['snippet']['thumbnails']['medium']['url'];
  //       final String backVideoId = index > 0 ? videos[index - 1]['id']['videoId'] ?? '' : ''; //現在のビデオがリストの先頭ではない場合
  //       final String forward = index < videos.length - 1 ? videos[index + 1]['id']['videoId']?? '' : ''; //現在のビデオがリストの最後ではない
  //       final bool isFirstVideo = index == 0; // 現在のビデオがリストの先頭かどうかを判定
  //       final bool isLastVideo = index == videos.length - 1; // 現在のビデオがリストの最後かどうかを判定
  //       final String previousVideoId = isFirstVideo ? '' : videos[index - 1]['id']['videoId'] ?? '';//現在のビデオリストが先頭じゃなかったら前のIDを取ってきている
  //       final String nextVideoId = isLastVideo ? '' : videos[index + 1]['id']['videoId'] ?? '';//現在のビデオがリストの最後じゃなかったら次のIDを取ってきている



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
              currentAccountPicture: _user != null ? CircleAvatar(
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
          '最新のおすすめ',
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
        future: recommendedVideosFuture,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to fetch recommended videos'));
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
                  final String backVideoId = index > 0 ? videos[index - 1]['id']['videoId'] ?? '' : ''; //前の動画
                  final String forward = index < videos.length - 1 ? videos[index + 1]['id']['videoId'] ?? '' : ''; //次の動画
                  final bool isFirstVideo = index == 0; // 現在のビデオがリストの先頭かどうかを判定
                  final bool isLastVideo = index == videos.length - 1; // 現在のビデオがリストの最後かどうかを判定
                  final String previousVideoId = isFirstVideo ? '' : videos[index - 1]['id']['videoId'] ?? '';
                  final String nextVideoId = isLastVideo ? '' : videos[index + 1]['id']['videoId'] ?? '';


                  return GestureDetector( //ユーザーのジェスチャー（タップ、スワイプ、ドラッグなど）を検出するためのウィジェット
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
                          Padding( //余白の追加
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