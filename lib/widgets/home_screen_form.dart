import 'package:flutter/material.dart';

class HomeScreenForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController timeController;
  final TextEditingController chlorineController;
  final VoidCallback onSubmit;
  final bool isSendDisabled;

  const HomeScreenForm({
    super.key,
    required this.formKey,
    required this.timeController,
    required this.chlorineController,
    required this.onSubmit,
    required this.isSendDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '測定データを入力してください',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildTimeInput(),
          const SizedBox(height: 16),
          _buildChlorineInput(),
          const SizedBox(height: 24),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildTimeInput() {
    return TextFormField(
      controller: timeController,
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
        if (value.length != 4 || !RegExp(r'^\d{4}$').hasMatch(value)) {
          return '4桁の数字で入力してください';
        }
        return null;
      },
    );
  }

  Widget _buildChlorineInput() {
    return TextFormField(
      controller: chlorineController,
      decoration: const InputDecoration(
        labelText: '残留塩素',
        hintText: '例: 0.40',
        border: OutlineInputBorder(),
        suffixText: 'mg/L',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: isSendDisabled ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('送信', style: TextStyle(fontSize: 16)),
    );
  }
}
