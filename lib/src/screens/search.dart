import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ncs_app/app_router.dart';
import 'dart:convert';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];

  Future<List<dynamic>> searchVideos(String query, String channelId) async {
    const String apiKey = 'AIzaSyCFMsc8U6804ORH2NO8HvGGgikpwvgZqLE'; // ご自身のYouTube APIキーに置き換えてください
    final String apiUrl = 'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&key=$apiKey&channelId=$channelId&q=';

    final response = await http.get(Uri.parse('$apiUrl$query'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to search videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '動画を検索',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  searchResults = []; // 検索結果をリセット
                });
                if (query.isNotEmpty) {
                  const channelId = 'UC_aEa8K-EOJ3D6gOs7HcyNg'; // チャンネルID
                  searchVideos(query, channelId).then((results) {
                    setState(() {
                      searchResults = results; // 検索結果を更新
                    });
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "NCSの動画を検索",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear), // バツ印アイコン
                  onPressed: () {
                    _searchController.clear(); // テキストをクリア
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                final video = searchResults[index];
                final String videoId = video['id']['videoId'];
                final String title = video['snippet']['title'];
                final String thumbnailUrl = video['snippet']['thumbnails']['medium']['url'];

                return Card(
                  child: ListTile(
                    leading: Image.network(thumbnailUrl),
                    title: Text(title),
                    onTap: () {
                      context.router.push(
                        VideoRoute(
                          videoId: videoId,
                          backVideoId: '',
                          forward: '',
                          nextVideoId: '',
                          previousVideoId: '',
                          videos: const [], 
                          thumbnailUrl: thumbnailUrl, 
                          title: title,
                          playlistName: '',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}