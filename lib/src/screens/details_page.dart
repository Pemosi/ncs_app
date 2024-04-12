import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/src/screens/play_from_library.dart';

@RoutePage()
class DetailsPage extends StatelessWidget {
  final String playlistName;
  final String playlistId;

  const DetailsPage({super.key, required this.playlistName, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          playlistName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('libraries') // プレイリストのデータがあるコレクションに変更
            .doc(playlistName) // プレイリスト名に合わせてドキュメントを指定
            .collection('videos')// 動画データがあるサブコレクションに変更
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

          return ListView.builder(
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LibraryVideoPage(
                        videoId: videoId, 
                        playlistName: playlistName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}