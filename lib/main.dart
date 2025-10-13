import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waqu_repo/screens/home_screen.dart';
import 'package:waqu_repo/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseの初期化
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '定型メール送信',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(child: HomeScreen()),
    );
  }
}
