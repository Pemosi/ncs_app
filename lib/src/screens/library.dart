import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ncs_app/src/screens/details_page.dart';

@RoutePage()
class LibraryPage extends StatefulWidget {
  final String videoId;
  final String forward;
  final String backVideoId;
  final String previousVideoId;
  final String nextVideoId;
  final List<dynamic> videos;
  final String title;
  final String thumbnailUrl;

  const LibraryPage({Key? key, required this.videoId, required this.videos, required this.title, required this.thumbnailUrl, required this.forward, required this.backVideoId, required this.previousVideoId, required this.nextVideoId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LibraryPageState createState() => _LibraryPageState();
}

// @RoutePage()
// class LibraryRouterPage extends AutoRouter {
//   const LibraryRouterPage({super.key});
// }

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _playlistController = TextEditingController();

  void _createPlaylist(String playlistName) { //ライブラリ作成
    FirebaseFirestore.instance.collection('playlistNames').add({
      'name': playlistName,
      'timestamp': DateTime.now(),
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('プレイリストが作成されました'),
      ));
      _playlistController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('プレイリストの作成中にエラーが発生しました：$error'),
      ));
    });
  }

  void _updatePlaylistName(String playlistId, String currentName, String newName) {
    FirebaseFirestore.instance.collection('playlistNames').doc(playlistId).update({
      'name': newName,
    }).then((value) {
      // プレイリスト名が更新された場合の処理
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('プレイリスト名が変更されました'),
      ));
    }).catchError((error) {
      // エラーが発生した場合の処理
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('プレイリスト名の変更中にエラーが発生しました：$error'),
      ));
    });
  }

  void _showPlaylistDetails(String playlistId, String playlistName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          playlistName: playlistName,
          playlistId: playlistId,
        ),
      ),
    );
  }

  void _editPlaylistName(String playlistId, String currentName) {
    final TextEditingController newNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('プレイリスト名を変更'),
          content: TextField(
            controller: newNameController,
            decoration: const InputDecoration(
              labelText: '新しいプレイリスト名',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final newName = newNameController.text.trim();
                if (newName.isNotEmpty) {
                  _updatePlaylistName(playlistId, currentName, newName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('変更'),
            ),
          ],
        );
      },
    );
  }


  void _deletePlaylist(String playlistId) { //ライブラリ削除
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('プレイリストを削除'),
          content: const Text('本当にこのプレイリストを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                _confirmDeletePlaylist(playlistId);
                Navigator.pop(context);
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePlaylist(String playlistId) { //ファイヤーベースからもプレイリストを削除している
    FirebaseFirestore.instance.collection('playlistNames').doc(playlistId).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('プレイリストが削除されました'),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('プレイリストの削除中にエラーが発生しました：$error'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ライブラリ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              final playlistId = playlists[index].id;

              return Card(
                child: ListTile(
                  title: Text(playlistName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit), // ライブラリ名を変更するためのアイコン
                        onPressed: () {
                          _editPlaylistName(playlistId, playlistName);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deletePlaylist(playlistId);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showPlaylistDetails(playlistId, playlistName);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('プレイリストを新しく作る'),
                content: TextField(
                  controller: _playlistController,
                  decoration: const InputDecoration(
                    labelText: 'プレイリスト名',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () {
                      final playlistName = _playlistController.text.trim();
                      if (playlistName.isNotEmpty) {
                        _createPlaylist(playlistName);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('作成'),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Playlist'),
      ),
    );
  }
}