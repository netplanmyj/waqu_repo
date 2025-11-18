import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waqu_repo/screens/home_screen.dart';
import 'package:waqu_repo/widgets/auth_wrapper.dart';

void main() async {
  // Flutter binding の初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase の初期化（必ず runApp より前に完了させる）
  await Firebase.initializeApp();

  // エッジツーエッジ表示のためのシステムUIオーバーレイ設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '定型メール送信',
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      // 初期化中でも画面を表示（AuthWrapperが処理）
      home: const AuthWrapper(child: HomeScreen()),
    );
  }
}
