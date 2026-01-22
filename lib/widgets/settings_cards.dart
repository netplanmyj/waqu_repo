import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;
  final IconData? icon;
  final Color? iconColor;

  const SettingsCard({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(icon, color: iconColor ?? Colors.grey[600]),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class LocationNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const LocationNumberField({
    super.key,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: '例: 01',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      validator: validator,
    );
  }
}

class EmailSubjectField extends StatelessWidget {
  final TextEditingController controller;

  const EmailSubjectField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: '例: 毎日検査報告',
        border: OutlineInputBorder(),
        helperText: '送信するメールの件名を設定できます',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'メール件名を入力してください';
        }
        return null;
      },
    );
  }
}

class EmailAddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;

  const EmailAddressField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: '例: report@example.com',
        border: const OutlineInputBorder(),
        helperText: 'メールアドレスを入力してください',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: validator,
    );
  }
}

class DebugModeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DebugModeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        value ? 'ON (テスト用送信先に送信)' : 'OFF (通常の送信先に送信)',
        style: TextStyle(
          color: value ? Colors.orange : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value
            ? 'メールはテスト用送信先に送信されます\n送信履歴の日次チェックも無効になります'
            : 'メールは通常の送信先に送信されます\n1日1回の送信制限が有効です',
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.orange,
    );
  }
}
