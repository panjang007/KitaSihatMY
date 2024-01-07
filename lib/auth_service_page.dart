import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to notify authentication changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
