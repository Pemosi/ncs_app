import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/app_router.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        // ここに各タブ画面のルートを追加する
        const HomeRouterRoute(),
        const LankingRoute(),
        const SearchRoute(),
        LibraryRoute(videoId: '', videos: const [], title: '', thumbnailUrl: '', forward: '', backVideoId: '', previousVideoId: '', nextVideoId: ''),
      ],
      builder: (context, child) {
        // タブが切り替わると発火します
        final tabsRouter = context.tabsRouter;
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              NavigationDestination(
                icon: Icon(Icons.flag),
                label: 'ランキング',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: '検索',
              ),
              NavigationDestination(
                icon: Icon(Icons.playlist_add_sharp),
                label: 'ライブラリ',
              ),
            ],
            onDestinationSelected: (index) {
              // タブが再度選択された場合
              if (index == tabsRouter.activeIndex) {
                // 一つ前の画面に戻る処理を実行
                tabsRouter.pop();
              } else {
                // 通常のタブ切り替え処理
                tabsRouter.setActiveIndex(index);
              }
            },
          ),
        );
      },
    );
  }
}