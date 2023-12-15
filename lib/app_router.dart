import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ncs_app/root_page.dart';
import 'package:ncs_app/src/screens/details_page.dart';
// import 'package:ncs_app/src/screens/details_page.dart';
import 'package:ncs_app/src/screens/home.dart';
import 'package:ncs_app/src/screens/library.dart';
import 'package:ncs_app/src/screens/login.dart';
// import 'package:ncs_app/src/screens/play_from_library.dart';
import 'package:ncs_app/src/screens/ranking.dart';
import 'package:ncs_app/src/screens/search.dart';
import 'package:ncs_app/src/screens/video.dart';
part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')      
class AppRouter extends _$AppRouter {      
  @override      
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/',
      page: RootRoute.page,
      children: [
        AutoRoute(
          path: 'home',
          page: HomeRouterRoute.page,
          children: [
            AutoRoute(
              initial: true,
              path: 'home',
              page: HomeRoute.page,
            ),
            AutoRoute(
              path: 'video',
              page: VideoRoute.page,
            ),
            AutoRoute(
              path: 'login',
              page: LoginRoute.page,
            ),
          ],
        ),

        AutoRoute(
          path: 'lanking',
          page: LankingRouterRoute.page,
          children: [
            AutoRoute(
              path: 'lanking',
              page: LankingRoute.page,
            ),
            AutoRoute(
              path: 'video',
              page: VideoRoute.page,
            ),
            AutoRoute(
              path: 'login',
              page: LoginRoute.page,
            ),
          ],
        ),

        AutoRoute(
          page: LoginRoute.page, //HomeRouterRouteのchildrenに入っているからログインの画面にボトムナビゲーションバーが表示されているつまりHomeRoute.pageの画面にログインページが上に重なっていると想定
          children: [
            AutoRoute(
              path: 'home',
              page: HomeRoute.page,
            ),
          ],
        ),

        AutoRoute(
          path: 'search',
          page: SearchRouterRoute.page,
          children: [
            AutoRoute(
              path: 'search',
              page: SearchRoute.page
            ),
            AutoRoute(
              path: 'video',
              page: VideoRoute.page,
            ),
            AutoRoute(
              path: 'login',
              page: LoginRoute.page,
            ),
          ],
        ),
        
        AutoRoute(
          path: 'library',
          page: LibraryRouterRoute.page,
          children: [
            AutoRoute(
              path: 'library',
              page: LibraryRoute.page,
            ),
            AutoRoute(
              path: 'details',
              page: DetailsRoute.page,
            ),
          ],
        ),
      ],
    ),
  ];
}