import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/app_router.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        // ここに各タブ画面のルートを追加する
        HomeRouterRoute(),
        LankingRoute(),
        SearchRoute(),
        LibraryRoute(),
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
              // 同じアイコンが再選択された場合、ホームに戻る
              if (tabsRouter.activeIndex == index) {
                context.router.popUntilRoot();
                print("動作はしてる");
              } else {
                tabsRouter.setActiveIndex(index);
                print("正常になっている");
              }
            },
          ),
        );
      },
    );
  }
}