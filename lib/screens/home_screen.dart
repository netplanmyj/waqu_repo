// lib/screens/home_screen.dart の内部

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/email_service.dart'; // サービスファイルをインポート
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ① 画面の状態を管理する変数
  bool _isSentToday = false;
  String _message = 'メッセージを送信できます。';

  // ② 入力フォーム用のコントローラー
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _chlorineController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _timeController.dispose();
    _chlorineController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkSentStatus();
  }

  // ② 状態チェックと更新のロジック
  void _checkSentStatus() async {
    // email_service.dart の関数を呼び出す
    _isSentToday = await isSentToday();

    if (_isSentToday) {
      // 送信済みの場合、日付を取得してメッセージに含める
      final prefs = await SharedPreferences.getInstance();
      final lastDateString = prefs.getString('lastSentDate');

      if (lastDateString != null) {
        final lastDate = DateTime.parse(lastDateString);
        setState(() {
          _message = '${lastDate.month}月${lastDate.day}日は送信済みです。';
        });
      } else {
        setState(() {
          _message = '本日の送信は完了済みです。';
        });
      }
    } else {
      setState(() {
        _message = '送信ボタンを押してください。';
      });
    }
  }

  void _handleSend() async {
    // 入力値の検証
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // 入力データを取得
    final time = _timeController.text;
    final chlorine = double.tryParse(_chlorineController.text);

    if (chlorine == null) {
      setState(() {
        _message = '残留塩素は数値で入力してください。';
      });
      return;
    }

    // 送信処理の実行
    final result = await sendDailyEmail(time: time, chlorine: chlorine);

    // 送信後に状態をチェック
    _isSentToday = await isSentToday();

    setState(() {
      // 送信結果をメッセージに設定
      _message = result;

      // 送信が成功した場合、次回からボタンを無効化
      // _isSentTodayは既に更新済み
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水質報告メール送信'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            tooltip: '送信履歴',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                '測定データを入力してください',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 測定時刻入力
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: '測定時刻（4桁）',
                  hintText: '例: 0950',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '測定時刻を入力してください';
                  }
                  if (value.length != 4 ||
                      !RegExp(r'^\d{4}$').hasMatch(value)) {
                    return '4桁の数字で入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 残留塩素入力
              TextFormField(
                controller: _chlorineController,
                decoration: const InputDecoration(
                  labelText: '残留塩素',
                  hintText: '例: 0.40',
                  border: OutlineInputBorder(),
                  suffixText: 'mg/L',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '残留塩素を入力してください';
                  }
                  final double? chlorine = double.tryParse(value);
                  if (chlorine == null) {
                    return '数値で入力してください';
                  }
                  if (chlorine < 0 || chlorine > 10) {
                    return '0〜10の範囲で入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 送信ボタン
              ElevatedButton(
                onPressed: _isSentToday ? null : _handleSend,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('水質報告メール送信', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),

              // メッセージ表示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isSentToday ? Colors.green[700] : Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
