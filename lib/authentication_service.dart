import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelp/screens/profile/components/profiles_db.dart';
import 'package:shelp/screens/profile/components/profile.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> deleteUser() async {
    try {
      await _firebaseAuth.currentUser.delete();
      return "User deleted!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed In!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      addProfile(new Profile.onlyIdandEmail(
          _firebaseAuth.currentUser.uid, _firebaseAuth.currentUser.email));
      return "Signed Up!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
