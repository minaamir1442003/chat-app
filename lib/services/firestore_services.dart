import 'package:chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> creatuser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception("failed to creat user: ${e.toString()}");
    }
  }

  Future<UserModel?> getuser(String userid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('faild to get user ${e.toString()}');
    }
  }

  Future<void> updateuseronlinestate(String userid, bool isonline) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userid).get();
      if (doc.exists) {
        await _firestore.collection('users').doc(userid).update({
          'isonline': isonline,
          'lastseen': DateTime.now(),
        });
      }
    } catch (e) {
      throw Exception('faild to get user online state ${e.toString()}');
    }
  }

  Future<void> deletuser(String userid) async {
    try {
      await _firestore.collection('users').doc(userid).delete();
    } catch (e) {
      throw Exception('faild to delet user ${e.toString()}');
    }
  }

  Stream<UserModel?> getuserstream(String userid) {
    return _firestore
        .collection('users')
        .doc(userid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<void> updateuser(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception("Failed to updateuser");
    }
  }
}
