// Dịch vụ Xác thực Firebase & Đăng nhập Google (Google Sign-In)
// Phục vụ Checklist 6: Phương án tích hợp Cloud

class MockFirebaseUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  MockFirebaseUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  MockFirebaseUser? _currentUser;
  MockFirebaseUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Đăng nhập bằng tài khoản Google (Google Sign-In)
  Future<MockFirebaseUser?> signInWithGoogle() async {
    // Trong môi trường thực tế khi cài đặt firebase_auth và google_sign_in:
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    // final AuthCredential credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    // return userCredential.user;

   
    _currentUser = MockFirebaseUser(
      uid: 'user-google-1029384756',
      email: 'phamvanhung21122004@gmail.com',
      displayName: 'Phạm Văn Hưng',
      photoUrl: 'https://lh3.googleusercontent.com/a/default-avatar',
    );
    return _currentUser;
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> signOut() async {
    _currentUser = null;
  }
}
