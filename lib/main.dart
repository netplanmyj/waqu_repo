import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waqu_repo/screens/home_screen.dart';
import 'package:waqu_repo/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseの初期化（エラーハンドリング：サイレント）
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    // Firebase初期化エラーをログに出力（ユーザーにはエラーを表示しない）
    debugPrint('❌ Firebase initialization error: $e');
    // エラーが発生してもアプリは起動する
  }

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Android 15以降でエッジツーエッジ表示を適用
        useMaterial3: true,
      ),
      home: const AuthWrapper(child: HomeScreen()),
    );
  }
}
