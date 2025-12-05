import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

ValueNotifier <AuthService> authServices = ValueNotifier(AuthService());
class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
  }
 Future<UserCredential> createAccount({
  required String email,
  required String password,
  required String username, // 👈 make username compulsory
}) async {
  try {
    // Create account
    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name with username
    await userCredential.user?.updateDisplayName(username);
    await userCredential.user?.reload();

    return userCredential;
  } catch (e) {
    print("Error signing up: $e");
    rethrow;
  }
}

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
  Future<void> resetPassword({
    required String email,
    }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
  Future<void> updateUsername ({
    required String username,
  }) async {
    await currentUser?.updateDisplayName(username);
  }
  Future<void>deleteAccount({
    required String email,
    required String password,
  }) async{
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.delete();
    await signOut();
  }
}