import 'package:chat/models/user_model.dart';
import 'package:chat/services/firestore_services.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreServices _firebaseservices = FirestoreServices();
  User? get currentUser => _auth.currentUser;
  String? get currentuserId => _auth.currentUser?.uid;
  Stream<User?> get authstateChanges => _auth.authStateChanges();
  Future<UserModel?> signinwithemailandpassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _firebaseservices.updateuseronlinestate(user.uid, true);
        return await _firebaseservices.getuser(user.uid);
      }
      return null;
    } catch (e) {
      throw Exception("failed to signin in $e");
    }
  }

  Future<UserModel?> registerwithemailandpassword(
    String email,
    String password,
    String displayname,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(displayname);
        final usermodel = UserModel(
          id: user.uid,
          email: email,
          displayname: displayname,
          photourl: '',
          isonline: true,
          lastseen: DateTime.now(),
          createdat: DateTime.now(),
        );
        await _firebaseservices.creatuser(usermodel);
        return usermodel;
      }
      return null;
    } catch (e) {
      throw Exception("failed to signin in $e");
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Failed to send password reset email: $e");
    }
  }

  Future<void> signout() async {
    try {
      if (currentuserId != null) {
        await _firebaseservices.updateuseronlinestate(currentuserId!, false);
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception("Failed to sign out: $e");
    }
  }

  Future<void> deletacount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firebaseservices.deletuser(user.uid);
        await user.delete();
      }
    } catch (e) {
      throw Exception("Failed to delet acount: $e");
    }
  }
}
