// lib/screens/home_screen.dart の内部

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gmail_service.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../widgets/account_dialog.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDemoMode;

  const HomeScreen({super.key, this.isDemoMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ① 画面の状態を管理する変数
  bool _isSentToday = false;
  String _message = 'データを入力して送信ボタンを押してください';
  bool _isDebugMode = false; // デバッグモードの状態を保持
  bool _isSending = false; // 送信中フラグ（二重送信防止）

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
    // 設定を取得してデバッグモードを確認
    final settings = await SettingsService.getSettings();

    // デバッグモードの状態を保存
    if (mounted) {
      setState(() {
        _isDebugMode = settings.isDebugMode;
      });
    }

    // デバッグモードの場合は常に送信可能
    if (settings.isDebugMode) {
      if (mounted) {
        setState(() {
          _isSentToday = false;
          _message = '【デバッグモード】何度でも送信できます';
        });
      }
      return;
    }

    // 通常モードの場合、email_service.dart の関数を呼び出す
    _isSentToday = await isSentToday();

    if (_isSentToday) {
      // 送信済みの場合、日付を取得してメッセージに含める
      final prefs = await SharedPreferences.getInstance();
      final lastDateString = prefs.getString('lastSentDate');

      if (lastDateString != null) {
        final lastDate = DateTime.parse(lastDateString);
        if (mounted) {
          setState(() {
            _message = '${lastDate.month}月${lastDate.day}日に送信済みです';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _message = '本日は送信済みです';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _message = 'データを入力して送信ボタンを押してください';
        });
      }
    }
  }

  void _handleSend() async {
    // 二重送信防止
    if (_isSending) {
      return;
    }

    // 入力値の検証
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // 送信中フラグをON
    setState(() {
      _isSending = true;
      _message = '送信中...';
    });

    try {
      // 入力データを取得
      final time = _timeController.text;
      final chlorine = double.tryParse(_chlorineController.text);

      if (chlorine == null) {
        if (mounted) {
          setState(() {
            _message = '残留塩素は数値で入力してください。';
            _isSending = false;
          });
        }
        return;
      }

      // デモモードの場合は実際の送信をスキップ
      final String result;
      if (widget.isDemoMode) {
        // デモモード: 送信をシミュレート
        await Future.delayed(const Duration(seconds: 1));
        result = '【デモモード】送信をシミュレートしました\n時刻: $time\n残留塩素: $chlorine mg/L';
      } else {
        // 通常モード: 実際に送信
        result = await sendDailyEmail(time: time, chlorine: chlorine);
      }

      // 送信後に状態をチェック（デバッグモードも考慮、デモモードは除外）
      if (mounted) {
        if (!widget.isDemoMode) {
          _checkSentStatus();
        }

        setState(() {
          // 送信結果をメッセージに設定
          _message = result;
          _isSending = false;
        });
      }
    } catch (e) {
      // エラーが発生した場合
      if (mounted) {
        setState(() {
          _message = 'エラーが発生しました: $e';
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水質報告メール送信'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        // デモモードバナーを表示
        bottom: widget.isDemoMode
            ? PreferredSize(
                preferredSize: const Size.fromHeight(32),
                child: Container(
                  color: Colors.orange[700],
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.preview, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Demo Mode (for App Review)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        actions: [
          // ユーザー情報表示（デモモード時はダミー情報）
          if (widget.isDemoMode || AuthService.userEmail != null)
            GestureDetector(
              onTap: _showAccountDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // デバッグモード時はアイコンを表示
                      if (_isDebugMode)
                        const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(Icons.bug_report, size: 14),
                        ),
                      CircleAvatar(
                        radius: 12,
                        backgroundImage:
                            !widget.isDemoMode &&
                                AuthService.userPhotoUrl != null
                            ? NetworkImage(AuthService.userPhotoUrl!)
                            : null,
                        backgroundColor: Colors.blue[300],
                        child:
                            !widget.isDemoMode &&
                                    AuthService.userPhotoUrl == null ||
                                widget.isDemoMode
                            ? const Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.isDemoMode
                            ? 'demo@example.com'
                            : _isDebugMode
                            ? 'demo-user' // デバッグモード時のダミー名
                            : AuthService.userEmail!.split('@')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Navigatorを非同期処理前に保存
              final navigator = Navigator.of(context);

              // 設定画面から戻った時に状態を更新
              await navigator.push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              // 設定が変更された可能性があるので状態をチェック
              if (mounted) {
                _checkSentStatus();
              }
            },
            tooltip: '設定',
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
                onPressed: (_isSentToday || _isSending) ? null : _handleSend,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSending
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('送信中', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : const Text('送信', style: TextStyle(fontSize: 16)),
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

  // アカウント情報ダイアログを表示
  void _showAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AccountDialog(isDebugMode: _isDebugMode),
    );
  }
}
