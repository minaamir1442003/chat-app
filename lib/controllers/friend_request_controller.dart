import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/models/frind_reqist_state.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendRequestController extends GetxController {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<FrindReqistModel> _receivedrequsts = <FrindReqistModel>[].obs;
  final RxList<FrindReqistModel> _sendrequests = <FrindReqistModel>[].obs;
  final RxMap<String, UserModel> _user = <String, UserModel>{}.obs;
  final RxBool _isloading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _selectedtabindex = 0.obs;
  List<FrindReqistModel> get receivedrequests => _receivedrequsts;
  List<FrindReqistModel> get sentrequests => _sendrequests;
  Map<String, UserModel> get user => _user;
  bool get isloading => _isloading.value;
  String get error => _error.value;
  int get selectedtabindex => _selectedtabindex.value;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loafriendrequests();
    _loadusers();
  }

  void _loafriendrequests() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      _receivedrequsts.bindStream(
        _firestoreServices.getfriendrequeststream(currentuserid),
      );
      _sendrequests.bindStream(
        _firestoreServices.getsentfriendrequestsstream(currentuserid),
      );
    }
  }

  void _loadusers() {
    _user.bindStream(
      _firestoreServices.getallusersstream().map((userlist) {
        Map<String, UserModel> usermap = {};
        for (var user in userlist) {
          usermap[user.id] = user;
        }
        return usermap;
      }),
    );
  }

  void changetab(int index) {
    _selectedtabindex.value = index;
  }

  UserModel? getuser(String userid) {
    return _user[userid];
  }

  Future<void> acceptrequest(FrindReqistModel request) async {
    try {
      _isloading.value = true;
      await _firestoreServices.respondtofriendrequest(
        request.id,
        FrindReqistState.accepted,
      );
      Get.snackbar("success", "frend request accepted");
    } catch (e) {
      print(e.toString());
      _error.value = "failled to accept friend request";
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> declinefriendrequest(FrindReqistModel request) async {
    try {
      _isloading.value = true;
      await _firestoreServices.respondtofriendrequest(
        request.id,
        FrindReqistState.declined,
      );
      Get.snackbar("success", "frend request declined");
    } catch (e) {
      print(e.toString());
      _error.value = "failled to declined friend request";
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> unblockuser(String userid) async {
    try {
      _isloading.value = true;
      await _firestoreServices.unblockeduser(_authController.user!.uid, userid);
      Get.snackbar("success", "user unlocked successfully");
    } catch (e) {
      print(e.toString());
      _error.value = "failled to unblock user";
    } finally {
      _isloading.value = false;
    }
  }

  String getrequesttimetext(DateTime createdat) {
    final now = DateTime.now();
    final difference = now.difference(createdat);
    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minute ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  String getstatustext(FrindReqistState status) {
    switch (status) {
      case FrindReqistState.pending:
        return "pending";
      case FrindReqistState.accepted:
        return "Accepted";
      case FrindReqistState.declined:
        return "Declined";
    }
  }

  Color getstatuscolor(FrindReqistState status) {
    switch (status) {
      case FrindReqistState.pending:
        return Colors.orange;
      case FrindReqistState.accepted:
        return Colors.green;
      case FrindReqistState.declined:
        return Colors.redAccent;
    }
  }

  void clearerror() {
    _error.value = "";
  }
}
