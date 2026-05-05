import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';
import 'responsive.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _email = TextEditingController(text: 'minhhoang@teamtask.vn');
  final _pass  = TextEditingController(text: 'password');
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Tài khoản'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: mobile ? double.infinity : 360),
            child: AppCard(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo icon
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.format_list_bulleted, size: 24, color: Colors.white),
                ),
                const SizedBox(height: 14),
                const Text('Đăng nhập',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextMain)),
                const SizedBox(height: 4),
                const Text('TeamTask · Quản lý công việc nhóm',
                    style: TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 24),

                // Email field
                _fieldLabel('Email'),
                _inputBox(
                  controller: _email,
                  hint: 'name@example.com',
                ),
                const SizedBox(height: 12),

                // Password field
                _fieldLabel('Mật khẩu'),
                _inputBox(
                  controller: _pass,
                  hint: '••••••••',
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18, color: kTextMuted),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 18),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    onPressed: () {},
                    child: const Text('Đăng nhập'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Chưa có tài khoản? ',
                      style: TextStyle(fontSize: 13, color: kTextMuted)),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('Đăng ký',
                        style: TextStyle(fontSize: 13, color: kAccent, fontWeight: FontWeight.w500)),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontSize: 12, color: kTextMuted)),
    ),
  );

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 13, color: kTextMain),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kTextMuted),
          suffixIcon: suffix,
          isDense: true,
          filled: true,
          fillColor: kAppBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kBorder, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kBorder, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kAccent),
          ),
        ),
      );
}