import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // current user
  User? get currentUser => _auth.currentUser;

  // auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // register
  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // login
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
