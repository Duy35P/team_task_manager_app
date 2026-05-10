import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// User hiện tại (null nếu chưa đăng nhập)
  User? get currentUser => _auth.currentUser;

  /// Stream theo dõi trạng thái đăng nhập (login / logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Đăng nhập ───────────────────────────────────────────────────────────────
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ── Đăng ký ─────────────────────────────────────────────────────────────────
  Future<UserCredential> register(
      String email, String password, String name) async {
    // 1. Tạo tài khoản trên Firebase Auth
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Cập nhật displayName
    await cred.user?.updateDisplayName(name);

    // 3. Tạo document user trên Firestore
    final user = cred.user;
    if (user != null) {
      final initials = _makeInitials(name);
      await _db.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'initials': initials,
        'avatarColorIndex': 0,
        'groupIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return cred;
  }

  // ── Đăng xuất ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Quên mật khẩu ──────────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Helper: tạo chữ viết tắt từ tên ────────────────────────────────────────
  String _makeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
  }

  // ── Helper: chuyển FirebaseAuthException thành thông báo tiếng Việt ─────────
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Kiểm tra internet.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}
