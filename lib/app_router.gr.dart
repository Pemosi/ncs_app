// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    DetailsRoute.name: (routeData) {
      final args = routeData.argsAs<DetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DetailsPage(
          key: args.key,
          playlistName: args.playlistName,
          playlistId: args.playlistId,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    HomeRouterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeRouterPage(),
      );
    },
    LankingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LankingPage(),
      );
    },
    LankingRouterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LankingRouterPage(),
      );
    },
    LibraryRoute.name: (routeData) {
      final args = routeData.argsAs<LibraryRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LibraryPage(
          key: args.key,
          videoId: args.videoId,
          videos: args.videos,
          title: args.title,
          thumbnailUrl: args.thumbnailUrl,
          forward: args.forward,
          backVideoId: args.backVideoId,
          previousVideoId: args.previousVideoId,
          nextVideoId: args.nextVideoId,
        ),
      );
    },
    LibraryRouterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LibraryRouterPage(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    RootRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RootPage(),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchPage(),
      );
    },
    SearchRouterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchRouterPage(),
      );
    },
    VideoRoute.name: (routeData) {
      final args = routeData.argsAs<VideoRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: VideoPage(
          videoId: args.videoId,
          key: args.key,
          forward: args.forward,
          backVideoId: args.backVideoId,
          previousVideoId: args.previousVideoId,
          nextVideoId: args.nextVideoId,
          videos: args.videos,
          title: args.title,
          thumbnailUrl: args.thumbnailUrl,
          playlistName: args.playlistName,
        ),
      );
    },
  };
}

/// generated route for
/// [DetailsPage]
class DetailsRoute extends PageRouteInfo<DetailsRouteArgs> {
  DetailsRoute({
    Key? key,
    required String playlistName,
    required String playlistId,
    List<PageRouteInfo>? children,
  }) : super(
          DetailsRoute.name,
          args: DetailsRouteArgs(
            key: key,
            playlistName: playlistName,
            playlistId: playlistId,
          ),
          initialChildren: children,
        );

  static const String name = 'DetailsRoute';

  static const PageInfo<DetailsRouteArgs> page =
      PageInfo<DetailsRouteArgs>(name);
}

class DetailsRouteArgs {
  const DetailsRouteArgs({
    this.key,
    required this.playlistName,
    required this.playlistId,
  });

  final Key? key;

  final String playlistName;

  final String playlistId;

  @override
  String toString() {
    return 'DetailsRouteArgs{key: $key, playlistName: $playlistName, playlistId: $playlistId}';
  }
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeRouterPage]
class HomeRouterRoute extends PageRouteInfo<void> {
  const HomeRouterRoute({List<PageRouteInfo>? children})
      : super(
          HomeRouterRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRouterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LankingPage]
class LankingRoute extends PageRouteInfo<void> {
  const LankingRoute({List<PageRouteInfo>? children})
      : super(
          LankingRoute.name,
          initialChildren: children,
        );

  static const String name = 'LankingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LankingRouterPage]
class LankingRouterRoute extends PageRouteInfo<void> {
  const LankingRouterRoute({List<PageRouteInfo>? children})
      : super(
          LankingRouterRoute.name,
          initialChildren: children,
        );

  static const String name = 'LankingRouterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LibraryPage]
class LibraryRoute extends PageRouteInfo<LibraryRouteArgs> {
  LibraryRoute({
    Key? key,
    required String videoId,
    required List<dynamic> videos,
    required String title,
    required String thumbnailUrl,
    required String forward,
    required String backVideoId,
    required String previousVideoId,
    required String nextVideoId,
    List<PageRouteInfo>? children,
  }) : super(
          LibraryRoute.name,
          args: LibraryRouteArgs(
            key: key,
            videoId: videoId,
            videos: videos,
            title: title,
            thumbnailUrl: thumbnailUrl,
            forward: forward,
            backVideoId: backVideoId,
            previousVideoId: previousVideoId,
            nextVideoId: nextVideoId,
          ),
          initialChildren: children,
        );

  static const String name = 'LibraryRoute';

  static const PageInfo<LibraryRouteArgs> page =
      PageInfo<LibraryRouteArgs>(name);
}

class LibraryRouteArgs {
  const LibraryRouteArgs({
    this.key,
    required this.videoId,
    required this.videos,
    required this.title,
    required this.thumbnailUrl,
    required this.forward,
    required this.backVideoId,
    required this.previousVideoId,
    required this.nextVideoId,
  });

  final Key? key;

  final String videoId;

  final List<dynamic> videos;

  final String title;

  final String thumbnailUrl;

  final String forward;

  final String backVideoId;

  final String previousVideoId;

  final String nextVideoId;

  @override
  String toString() {
    return 'LibraryRouteArgs{key: $key, videoId: $videoId, videos: $videos, title: $title, thumbnailUrl: $thumbnailUrl, forward: $forward, backVideoId: $backVideoId, previousVideoId: $previousVideoId, nextVideoId: $nextVideoId}';
  }
}

/// generated route for
/// [LibraryRouterPage]
class LibraryRouterRoute extends PageRouteInfo<void> {
  const LibraryRouterRoute({List<PageRouteInfo>? children})
      : super(
          LibraryRouterRoute.name,
          initialChildren: children,
        );

  static const String name = 'LibraryRouterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RootPage]
class RootRoute extends PageRouteInfo<void> {
  const RootRoute({List<PageRouteInfo>? children})
      : super(
          RootRoute.name,
          initialChildren: children,
        );

  static const String name = 'RootRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchRouterPage]
class SearchRouterRoute extends PageRouteInfo<void> {
  const SearchRouterRoute({List<PageRouteInfo>? children})
      : super(
          SearchRouterRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRouterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [VideoPage]
class VideoRoute extends PageRouteInfo<VideoRouteArgs> {
  VideoRoute({
    required String videoId,
    Key? key,
    required String forward,
    required String backVideoId,
    required String previousVideoId,
    required String nextVideoId,
    required List<dynamic> videos,
    required String title,
    required String thumbnailUrl,
    required String playlistName,
    List<PageRouteInfo>? children,
  }) : super(
          VideoRoute.name,
          args: VideoRouteArgs(
            videoId: videoId,
            key: key,
            forward: forward,
            backVideoId: backVideoId,
            previousVideoId: previousVideoId,
            nextVideoId: nextVideoId,
            videos: videos,
            title: title,
            thumbnailUrl: thumbnailUrl,
            playlistName: playlistName,
          ),
          initialChildren: children,
        );

  static const String name = 'VideoRoute';

  static const PageInfo<VideoRouteArgs> page = PageInfo<VideoRouteArgs>(name);
}

class VideoRouteArgs {
  const VideoRouteArgs({
    required this.videoId,
    this.key,
    required this.forward,
    required this.backVideoId,
    required this.previousVideoId,
    required this.nextVideoId,
    required this.videos,
    required this.title,
    required this.thumbnailUrl,
    required this.playlistName,
  });

  final String videoId;

  final Key? key;

  final String forward;

  final String backVideoId;

  final String previousVideoId;

  final String nextVideoId;

  final List<dynamic> videos;

  final String title;

  final String thumbnailUrl;

  final String playlistName;

  @override
  String toString() {
    return 'VideoRouteArgs{videoId: $videoId, key: $key, forward: $forward, backVideoId: $backVideoId, previousVideoId: $previousVideoId, nextVideoId: $nextVideoId, videos: $videos, title: $title, thumbnailUrl: $thumbnailUrl, playlistName: $playlistName}';
  }
}
