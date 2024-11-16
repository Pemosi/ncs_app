import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ncs_app/src/screens/home.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailTextController = TextEditingController();
  final _passwordNameTextController = TextEditingController();
  final FocusNode _userNamefocusNode = FocusNode();
  final FocusNode _passwordNameFocusNode = FocusNode();
  var _errorMessage = "";
  bool _obscureText = true;
  bool _isLoading = false;

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if (googleAuth != null && (googleAuth.accessToken != null || googleAuth.idToken != null)) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      print("Googleサインインできませんでした。");
      return null;
    }
  }

  Future<void> _signInWithLine() async {
    if (_isLoading) return;  // ローディング中なら処理を中断
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);

      if (result.userProfile != null) {
        // Firestoreにユーザー情報を保存
        // await ref.read(authProvider).saveUserToFirestore(...);
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on PlatformException catch (e) {
      // ignore: use_build_context_synchronously
      _showDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      icon: Icon(Icons.email),
      labelText: 'メールアドレス',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.asset(
          '/Users/muratareo/Desktop/ncs_app/assets/images/ncs.png',
          height: 80,
          width: 80,
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(
              Buttons.Google,
              onPressed: () {
                signInWithGoogle();
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
            ElevatedButton(
              onPressed: (){
                _signInWithLine();
              },
              child: const Text("LINEでログイン"),
            ),
            const SizedBox(height: 50),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const Text(
              "メールアドレスを入力・設定してください",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: _emailTextController,
                decoration: inputDecoration,
                focusNode: _userNamefocusNode,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "パスワードを入力・設定",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: _passwordNameTextController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  icon: const Icon(Icons.lock),
                  labelText: 'パスワード',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                focusNode: _passwordNameFocusNode,
                obscureText: _obscureText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 20),
                ElevatedButton(
                  child: const Text(
                    'ログイン',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    final String email = _emailTextController.text;
                    final String password = _passwordNameTextController.text;

                    try {
                      // ignore: unused_local_variable
                      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ignore: deprecated_member_use, use_build_context_synchronously
                      AutoRouter.of(context).pop();
                    } catch (e) {
                      setState(() {
                        _errorMessage = "ログインに失敗しました: $e";
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  child: const Text(
                    '新規登録',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    final String email = _emailTextController.text;
                    final String password = _passwordNameTextController.text;

                    try {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ignore: deprecated_member_use, use_build_context_synchronously
                      AutoRouter.of(context).pop();
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
          ],
        ),
      ),
    );
  }
}