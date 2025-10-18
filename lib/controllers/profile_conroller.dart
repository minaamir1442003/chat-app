import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirestoreServices _firestoreservices = FirestoreServices();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController displaynamecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final RxBool _isloading = false.obs;
  final RxBool _isediting = false.obs;
  final RxString _error = "".obs;
  final Rx<UserModel?> _currentuser = Rx<UserModel?>(null);
  bool get isloading => _isloading.value;
  bool get isediting => _isediting.value;
  String get error => _error.value;
  UserModel? get currentuser => _currentuser.value;
  @override
  void onInit() {
    super.onInit();
    _loaduserdata();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    // emailcontroller.dispose();
    // displaynamecontroller.dispose();
  }

  void _loaduserdata() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      print("Current User ID: $currentuserid");
      _currentuser.bindStream(_firestoreservices.getuserstream(currentuserid));
      ever(_currentuser, (UserModel? user) {
        if (user != null) {
          displaynamecontroller.text = user.displayname;
          emailcontroller.text = user.email;
        }
      });
    }
  }

  void toggleediting() {
    _isediting.value = !_isediting.value;
    if (_isediting.value) {
      final user = _currentuser.value;
      if (user != null) {
        displaynamecontroller.text = user.displayname;
        emailcontroller.text = user.email;
      }
    }
  }

  Future<void> updateprofile() async {
    try {
      _isloading.value = true;
      _error.value = "";
      final user = _currentuser.value;
      if (user == null) return;
      final updateduser = user.copyWith(
        displayname: displaynamecontroller.text,
      );
      await _firestoreservices.updateuser(updateduser);
      _isediting.value = false;
      Get.snackbar("Success", "profile updated sucesses");
    } catch (e) {
      _error.value = e.toString();
      print(e.toString());
      Get.snackbar("Error", "failled to update profile");
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> signout() async {
    try {
      await _authController.signout();
    } catch (e) {
      Get.snackbar("Error", "failled to sign out");
    } 
  }

  Future<void> deletaccount() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Delete Account"),
          content: Text(
            "Are You Sure you want to delete your account? this action can not be undone",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (result == true) {
        _isloading.value = true;
        await _authController.deletacount();
      }
    } catch (e) {
      Get.snackbar("error", "Faield to delet account");
    } finally {
      _isloading.value = false;
    }
  }

  String getjoineddata() {
    final user = _currentuser.value;
    if (user == null) return "";
    final data = user.createdat;
    final monthes = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "Joined ${monthes[data.month - 1]} ${data.year}";
  }

  void clearError() {
    _error.value = '';
  }
}
