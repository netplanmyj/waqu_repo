import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waqu_repo/screens/home_screen.dart';
import 'package:waqu_repo/widgets/auth_wrapper.dart';

void main() {
  // 重要: asyncを削除し、初期化を待たずに即座にアプリを起動
  WidgetsFlutterBinding.ensureInitialized();

  // エッジツーエッジ表示のためのシステムUIオーバーレイ設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // アプリを即座に起動（白い画面を回避）
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Firebase初期化をバックグラウンドで実行
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('⏱️ Firebase initialization timed out');
          throw TimeoutException('Firebase timeout');
        },
      );
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization error: $e');
      // エラーでも継続（AuthWrapperで処理）
    }
  }

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
