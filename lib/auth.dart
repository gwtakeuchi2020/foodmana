import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './common/beans.dart';

class Auth extends StatefulWidget{
  const Auth({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}
class _AuthState extends State<Auth>{
  // 新規登録メールアドレス
  String newUserEmail = "";
  // 新規登録パスワード
  String newUserPassword = "";
  // 入力されたメールアドレス（ログイン）
  String loginUserEmail = "";
  // 入力されたパスワード（ログイン）
  String loginUserPassword = "";
  // 登録・ログインに関する情報を表示
  String infoText = "";

  void _popUp() {
    showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: Text('新規ユーザ登録', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[200]), textAlign: TextAlign.center,),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextFormField(
                // テキスト入力のラベルを設定
                decoration: const InputDecoration(labelText: "メールアドレス"),
                onChanged: (String value) {
                  setState(() {
                    newUserEmail = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: "パスワード（６文字以上）"),
                // パスワードが見えないようにする
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    newUserPassword = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('キャンセル', style: TextStyle(color: Colors.white, fontSize: 20)),
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              onPrimary: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.pop(context)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text("新規登録", style: TextStyle(color: Colors.white, fontSize: 20)),
            onPressed: () async {
                  try {
                    // メール/パスワードでユーザー登録
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final UserCredential result =
                        await auth.createUserWithEmailAndPassword(
                      email: newUserEmail,
                      password: newUserPassword,
                    );

                    // 登録したユーザー情報
                    final User user = result.user!;
                    setState(() {
                      infoText = "登録OK：${user.email}";
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    // 登録に失敗した場合
                    setState(() {
                      infoText = "登録NG：${e.toString()}";
                    });
                    Navigator.pop(context);
                  }
                },
          )
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text(
          'Foodmana',
          style: TextStyle(fontSize: 20),
        ),
        automaticallyImplyLeading: false,
      ),
      body:Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              margin: const EdgeInsets.all(20),
              elevation: 3,
              child: Column(
                children: [
                  Text('SignIn', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.pink[200]), textAlign: TextAlign.center,),
                  Card(
                    color: Colors.red[400],
                    child: Text(infoText, style: const TextStyle(color: Colors.white))
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: "メールアドレス"),
                          onChanged: (String value) {
                            setState(() {
                              loginUserEmail = value;
                            });
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: "パスワード"),
                          obscureText: true,
                          onChanged: (String value) {
                            setState(() {
                              loginUserPassword = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          child: const Text("ログイン"),
                          onPressed: () async {
                            try {
                              // メール/パスワードでログイン
                              final FirebaseAuth auth = FirebaseAuth.instance;
                              final UserCredential result =
                                  await auth.signInWithEmailAndPassword(
                                email: loginUserEmail,
                                password: loginUserPassword,
                              );
                              // ログインに成功した場合、ログイン情報を格納
                              final User user = result.user!;
                              Beans.setUserId(user.email.toString());
                              // ホーム画面へ遷移
                              Navigator.pushNamed(context, '/navi');
                            } catch (e) {
                              // ログインに失敗した場合
                              setState(() {
                                infoText = e.toString(); //.authValidate(e, method);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: '新規登録は',
                                style: TextStyle(color: Colors.black)),
                              TextSpan(
                                text: 'こちら',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _popUp();
                                  }
                              ),
                            ]
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}