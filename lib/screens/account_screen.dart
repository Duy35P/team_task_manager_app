import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../widgets/app_top_bar.dart';
import '../responsive.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _authService = AuthService();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  // ── Đăng nhập ─────────────────────────────────────────────────────────────
  Future<void> _login() async {
    final email = _email.text.trim();
    final pass  = _pass.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showSnack('Vui lòng nhập đầy đủ email và mật khẩu.', isError: true);
      return;
    }
    final emailRx = RegExp(r'^[\w\-.]+@[\w\-.]+\.\w+$');
    if (!emailRx.hasMatch(email)) {
      _showSnack('Email không hợp lệ.', isError: true);
      return;
    }
    if (pass.length < 6) {
      _showSnack('Mật khẩu phải có ít nhất 6 ký tự.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.signIn(email, pass);
      if (mounted) {
        _showSnack('Đăng nhập thành công! 👋');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showSnack(AuthService.getErrorMessage(e), isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Đã xảy ra lỗi: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Đăng ký ───────────────────────────────────────────────────────────────
  void _openRegister() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    bool obscureReg = true;
    bool regLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Tạo tài khoản mới',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
          content: SizedBox(
            width: 320,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dlgField(nameCtrl,  'Họ và tên',  'Nguyễn Văn A'),
              const SizedBox(height: 10),
              _dlgField(emailCtrl, 'Email',       'name@example.com'),
              const SizedBox(height: 10),
              TextField(
                controller: passCtrl,
                obscureText: obscureReg,
                style: const TextStyle(fontSize: 13, color: kTextMain),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  labelStyle: const TextStyle(fontSize: 12, color: kTextMuted),
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: kTextMuted),
                  isDense: true,
                  filled: true,
                  fillColor: kAppBg,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureReg ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18, color: kTextMuted,
                    ),
                    onPressed: () => setDlg(() => obscureReg = !obscureReg),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kBorder, width: 0.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kBorder, width: 0.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kAccent)),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: regLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Huỷ', style: TextStyle(color: kTextMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: regLoading ? null : () async {
                final n = nameCtrl.text.trim();
                final e = emailCtrl.text.trim();
                final p = passCtrl.text.trim();
                if (n.isEmpty || e.isEmpty || p.isEmpty) {
                  Navigator.pop(ctx);
                  _showSnack('Vui lòng điền đầy đủ thông tin.', isError: true);
                  return;
                }
                setDlg(() => regLoading = true);
                try {
                  await _authService.register(e, p, n);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    _showSnack('Tạo tài khoản thành công! Chào mừng $n 🎉');
                  }
                } on FirebaseAuthException catch (err) {
                  setDlg(() => regLoading = false);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    _showSnack(AuthService.getErrorMessage(err), isError: true);
                  }
                } catch (err) {
                  setDlg(() => regLoading = false);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    _showSnack('Lỗi: $err', isError: true);
                  }
                }
              },
              child: regLoading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 13)),
      backgroundColor: isError ? kCoral : kTeal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── Quên mật khẩu ─────────────────────────────────────────────────────────
  void _forgotPassword() {
    final emailCtrl = TextEditingController(text: _email.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Quên mật khẩu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Nhập email để nhận liên kết đặt lại mật khẩu.',
              style: TextStyle(fontSize: 13, color: kTextMuted)),
          const SizedBox(height: 12),
          _dlgField(emailCtrl, 'Email', 'name@example.com'),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) {
                Navigator.pop(ctx);
                _showSnack('Vui lòng nhập email.', isError: true);
                return;
              }
              Navigator.pop(ctx);
              try {
                await _authService.resetPassword(email);
                if (mounted) {
                  _showSnack('Đã gửi email đặt lại mật khẩu! Kiểm tra hộp thư của bạn.');
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  _showSnack(AuthService.getErrorMessage(e), isError: true);
                }
              } catch (e) {
                if (mounted) {
                  _showSnack('Lỗi: $e', isError: true);
                }
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  // ── Đăng xuất ─────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Đăng xuất',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
        content: const Text('Bạn có chắc muốn đăng xuất?',
            style: TextStyle(fontSize: 13, color: kTextMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kCoral, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
    }
  }

  Widget _dlgField(TextEditingController ctrl, String label, String hint) =>
      TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13, color: kTextMain),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: kTextMuted),
          hintText: hint,
          hintStyle: const TextStyle(color: kTextMuted),
          isDense: true, filled: true, fillColor: kAppBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder, width: 0.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder, width: 0.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kAccent)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final user = _authService.currentUser;

    // ── Nếu đã đăng nhập → hiện trang profile ────────────────────────────
    if (user != null) {
      return _buildProfilePage(user, mobile);
    }

    // ── Chưa đăng nhập → hiện form login ─────────────────────────────────
    return _buildLoginPage(mobile);
  }

  // ── Trang Profile (đã đăng nhập) ────────────────────────────────────────
  Widget _buildProfilePage(User user, bool mobile) {
    final displayName = user.displayName ?? 'User';
    final email = user.email ?? '';
    final initials = _getInitials(displayName);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Tài khoản'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: mobile ? double.infinity : 400),
            child: Column(children: [
              // ── Profile Card ──
              AppCard(
                child: Column(children: [
                  // Avatar lớn
                  Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(displayName,
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, color: kTextMain)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: const TextStyle(fontSize: 13, color: kTextMuted)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kTealLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('● Đang hoạt động',
                        style: TextStyle(fontSize: 11, color: kTeal, fontWeight: FontWeight.w500)),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Info Card ──
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Thông tin tài khoản',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextMain)),
                  const SizedBox(height: 14),
                  _infoRow(Icons.email_outlined, 'Email', email),
                  const Divider(height: 20, color: kBorder),
                  _infoRow(Icons.badge_outlined, 'Tên hiển thị', displayName),
                  const Divider(height: 20, color: kBorder),
                  _infoRow(Icons.fingerprint, 'UID', '${user.uid.substring(0, 12)}...'),
                  const Divider(height: 20, color: kBorder),
                  _infoRow(Icons.calendar_today_outlined, 'Ngày tạo',
                      user.metadata.creationTime?.toString().substring(0, 10) ?? '—'),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Nút Đăng xuất ──
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCoral.withValues(alpha: 0.1),
                    foregroundColor: kCoral,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: kCoral.withValues(alpha: 0.3)),
                    ),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Đăng xuất',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 18, color: kAccent),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, color: kTextMain, fontWeight: FontWeight.w500)),
      ]),
    ]);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
  }

  // ── Trang Login (chưa đăng nhập) ───────────────────────────────────────
  Widget _buildLoginPage(bool mobile) {
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
                _inputBox(controller: _email, hint: 'name@example.com'),
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
                const SizedBox(height: 8),

                // Quên mật khẩu
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _forgotPassword,
                    child: const Text('Quên mật khẩu?',
                        style: TextStyle(fontSize: 12, color: kAccent, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 14),

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
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Đăng nhập'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Chưa có tài khoản? ',
                      style: TextStyle(fontSize: 13, color: kTextMuted)),
                  GestureDetector(
                    onTap: _openRegister,
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
        onSubmitted: (_) => _login(),
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