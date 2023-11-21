//ボトムナビゲーションを表示
import 'package:flutter/material.dart';
import 'package:ncs_app/app_router.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      debugShowCheckedModeBanner: false,
      title: 'NCS_Music',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}