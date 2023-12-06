import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:ncs_app/src/screens/home.dart';
// import 'package:ncs_app/app_router.dart';
// import 'package:ncs_app/src/screens/home.dart';
// import 'package:firebase_core/firebase_core.dart';


@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailTextController = TextEditingController();
  final _passwordNameTextController = TextEditingController();
  final FocusNode _userNamefocusNode = FocusNode();
  final FocusNode _passwordNameFocusNode = FocusNode();
  var _errorMessage = "";

   Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if (googleAuth != null && (googleAuth.accessToken != null || googleAuth.idToken != null)) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print(credential);

      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      print("Googleサインインできませんでした。");
      // エラー処理またはメッセージの表示
      throw Exception("Googleサインインできませんでした。");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン・新規登録"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _emailTextController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'メールアドレス',
              ),
              focusNode: _userNamefocusNode,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordNameTextController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'パスワード',
              ),
              focusNode: _passwordNameFocusNode,
              obscureText: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    _emailTextController.clear();
                    _passwordNameTextController.clear();
                  },
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                    child: const Text('ログイン'),
                    onPressed: () async {
                    final String email = _emailTextController.text;
                    final String password = _passwordNameTextController.text;

                    try {
                      // Firebase Authenticationを使用してログイン
                      // ignore: unused_local_variable
                      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email, // 仮のユーザー名とパスワードを使用
                        password: password,
                      );

                      // ログインに成功した場合、HomeRouteに遷移
                      // ignore: use_build_context_synchronously
                      AutoRouter.of(context).pop();
                      print('ログインできてる');
                    } catch (e) {
                      setState(() {
                        _errorMessage = "ログインに失敗しました: $e";
                      });
                    }
                  }),
                const SizedBox(width: 16),
                ElevatedButton(
                  child: const Text('ユーザー登録'),
                  onPressed: () async {
                    final String email = _emailTextController.text;
                    final String password = _passwordNameTextController.text;

                    try {
                      // Firebase Authenticationを使用して新しいユーザーを登録
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // ユーザー登録に成功した場合、HomeRouteに遷移（または適切なルートに遷移）
                      // ignore: use_build_context_synchronously
                      AutoRouter.of(context).pop();
                      print('ユーザー登録できてる');
                    } catch (e) {
                      setState(() {
                        _errorMessage = "ユーザー登録に失敗しました: $e";
                      });
                    }
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Column(
                children: [
                  SignInButton(
                    Buttons.Google,
                    onPressed: () {
                      print("Googleのサインイン");
                      signInWithGoogle();
                    },
                  ),
                  SignInButton(
                    Buttons.FacebookNew,
                    onPressed: () {
                      // Facebookログインの処理を追加
                    },
                  ),
                  SignInButton(
                    Buttons.Twitter,
                    onPressed: () {
                      // Twitterログインの処理を追加
                    },
                  ),
                  SignInButton(
                    Buttons.Apple,
                    onPressed: () {
                      // Appleログインの処理を追加
                    },
                  ),
                  SignInButton(
                    Buttons.Email,
                    onPressed: () {
                      // Emailログインの処理を追加
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}