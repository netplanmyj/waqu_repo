import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/gmail_service.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../widgets/account_dialog.dart';
import '../services/history_service.dart';
import '../widgets/home_screen_form.dart';
import '../widgets/home_screen_message.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDemoMode;

  const HomeScreen({super.key, this.isDemoMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late TextEditingController _timeController;
  late TextEditingController _chlorineController;
  late GlobalKey<FormState> _formKey;

  bool _isSentToday = false;
  String _message = 'データを入力して送信ボタンを押してください';
  bool _isDebugMode = false;
  bool _isSending = false;
  bool _isLastHistoryLoading = false;
  bool _isDateInitialized = false;
  EmailHistory? _lastHistory;
  String _locationNumber = '01';
  DateTime? _lastCheckedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timeController = TextEditingController();
    _chlorineController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _initializeScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeController.dispose();
    _chlorineController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    if (!widget.isDemoMode) {
      Future.microtask(() async {
        await _checkSentStatus();
        _lastCheckedDate = DateTime.now();
      });
    }
    await _initializeDateFormatting();
    await _loadLastHistory();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('ja_JP', null);
    if (mounted) {
      setState(() {
        _isDateInitialized = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!widget.isDemoMode && _lastCheckedDate != null) {
        final now = DateTime.now();
        final lastChecked = _lastCheckedDate!;
        final dateChanged =
            lastChecked.year != now.year ||
            lastChecked.month != now.month ||
            lastChecked.day != now.day;

        if (dateChanged) {
          Future.microtask(() async {
            await _checkSentStatus();
            _lastCheckedDate = now;
          });
        }
      }
    }
  }

  Future<void> _checkSentStatus() async {
    final settings = await SettingsService.getSettings();

    if (mounted) {
      setState(() {
        _locationNumber = settings.locationNumber;
        _isDebugMode = settings.isDebugMode;
      });
    }

    if (settings.isDebugMode) {
      if (mounted) {
        setState(() {
          _isSentToday = false;
          _message = '【デバッグモード】何度でも送信できます';
        });
      }
      return;
    }

    _isSentToday = await isSentToday();

    if (_isSentToday) {
      final prefs = await SharedPreferences.getInstance();
      final lastDateString = prefs.getString('lastSentDate');

      final messageText = lastDateString != null
          ? '${DateTime.parse(lastDateString).month}月${DateTime.parse(lastDateString).day}日に送信済みです'
          : '本日は送信済みです';

      if (mounted) {
        setState(() {
          _message = messageText;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _message = 'データを入力して送信ボタンを押してください';
        });
      }
    }
  }

  Future<void> _loadLastHistory() async {
    setState(() {
      _isLastHistoryLoading = true;
    });

    final histories = await HistoryService.getHistories();
    final latest = histories.isNotEmpty ? histories.first : null;

    if (mounted) {
      setState(() {
        _lastHistory = latest;
        _isLastHistoryLoading = false;
      });
    }
  }

  void _handleSend() async {
    if (_isSending) return;
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isSending = true;
      _message = '送信中...';
    });

    try {
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

      final String result;
      if (widget.isDemoMode) {
        await Future.delayed(const Duration(seconds: 1));
        result = '【デモモード】送信をシミュレートしました\n時刻: $time\n残留塩素: $chlorine mg/L';
      } else {
        result = await sendDailyEmail(time: time, chlorine: chlorine);
      }

      if (mounted) {
        if (!widget.isDemoMode) {
          _checkSentStatus();
        }

        await _loadLastHistory();

        setState(() {
          _message = result;
          _isSending = false;
        });
      }
    } catch (e) {
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
        bottom: widget.isDemoMode ? _buildDemoModeBanner() : null,
        actions: [
          if (widget.isDemoMode || AuthService.userEmail != null)
            _buildUserInfoButton(),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
            tooltip: '送信履歴',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: '設定',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeScreenForm(
                formKey: _formKey,
                timeController: _timeController,
                chlorineController: _chlorineController,
                onSubmit: _handleSend,
                isSendDisabled: _isSentToday || _isSending,
              ),
              const SizedBox(height: 16),
              _isSending
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('送信中', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    )
                  : HomeScreenMessage(
                      message: _message,
                      isSentToday: _isSentToday,
                    ),
              const SizedBox(height: 16),
              HomeScreenHistory(
                lastHistory: _lastHistory,
                isLoading: _isLastHistoryLoading || !_isDateInitialized,
                locationNumber: _locationNumber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSize _buildDemoModeBanner() {
    return PreferredSize(
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
    );
  }

  Widget _buildUserInfoButton() {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AccountDialog(
          isDebugMode: _isDebugMode,
          isDemoMode: widget.isDemoMode,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isDebugMode)
                const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(Icons.bug_report, size: 14),
                ),
              CircleAvatar(
                radius: 12,
                backgroundImage:
                    !widget.isDemoMode && AuthService.userPhotoUrl != null
                    ? NetworkImage(AuthService.userPhotoUrl!)
                    : null,
                backgroundColor: Colors.blue[300],
                child: widget.isDemoMode || AuthService.userPhotoUrl == null
                    ? const Icon(Icons.person, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isDemoMode
                    ? 'demo@example.com'
                    : _isDebugMode
                    ? 'demo-user'
                    : AuthService.userEmail!.split('@')[0],
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToSettings() async {
    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    if (mounted) {
      _checkSentStatus();
    }
  }
}
