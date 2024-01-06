import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ncs_app/app_router.dart';
// import 'package:ncs_app/src/screens/details_page.dart';
import 'package:ncs_app/src/screens/login.dart';

@RoutePage()
class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LibraryPageState createState() => _LibraryPageState();
}

@RoutePage()
class LibraryRouterPage extends AutoRouter {
  const LibraryRouterPage({super.key});
}

class _LibraryPageState extends State<LibraryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    context.router.push(
      DetailsRoute(
        playlistName: playlistName,
        playlistId: playlistId,
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
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;

            if (user == null) {
              // ログインしていない場合の表示
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ログインしてください'),
                    ElevatedButton(
                      onPressed: () {
                        // ログイン画面に遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text('ログイン'),
                    ),
                  ],
                ),
              );
            }

            // ログイン済みの場合の表示
            return StreamBuilder<QuerySnapshot>(
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
                              icon: const Icon(Icons.edit),
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
            );
          } else {
            // データ取得中の場合はローディング表示
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // ログインしているか確認
          User? user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            // ログインしていない場合の処理
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('ログインが必要です'),
                  content: const Text('プレイリストを作成するにはログインが必要です。'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            // ログインしている場合の処理
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
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('プレイリストを作成'),
      ),
    );
  }
}