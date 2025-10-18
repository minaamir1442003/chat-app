import 'package:chat/controllers/auth_controoler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChangePasswordcontroller extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController currentpasswordcontroller =
      TextEditingController();
  final TextEditingController newpasswordcontroller = TextEditingController();
  final TextEditingController confirmpasswordcontroller =
      TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final RxBool _isloading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _obsscurecurrentpassword = true.obs;
  final RxBool _obsscurenewpassword = true.obs;
  final RxBool _obsecureconfirmpassword = true.obs;
  bool get isloading => _isloading.value;
  String get error => _error.value;
  bool get obsscurecurrentpassword => _obsscurecurrentpassword.value;
  bool get obsscurenewpassword => _obsscurenewpassword.value;
  bool get obsecureconfirmpassword => _obsecureconfirmpassword.value;
  @override
  void onClose() {
    currentpasswordcontroller.dispose();
    newpasswordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    super.onClose();
  }

  void togglecurrentpasswordvisiblity() {
    _obsscurecurrentpassword.value = !_obsscurecurrentpassword.value;
  }

  void togglenewpasswordvisiblity() {
    _obsscurenewpassword.value = !_obsscurenewpassword.value;
  }

  void toggleconfirmpasswordvisiblity() {
    _obsecureconfirmpassword.value = !_obsecureconfirmpassword.value;
  }

  Future<void> changepassword() async {
    if (!formkey.currentState!.validate()) return;
    try {
      _isloading.value = true;
      _error.value = '';
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("no user logged in");
      }

      await user.updatePassword(newpasswordcontroller.text);
      Get.snackbar(
        "Success",
        "password changed successfully",
        backgroundColor: Colors.green.withOpacity(.1),
        colorText: Colors.green,
        duration: Duration(seconds: 3),
      );
      currentpasswordcontroller.clear();
      newpasswordcontroller.clear();
      confirmpasswordcontroller.clear();
      await _authController.signout();
    } on FirebaseAuthException catch (e) {
      String errormessage;
      switch (e.code) {
        case 'wrong-password':
          errormessage = 'current password is incorrect';
          break;
        case 'weak-password':
          errormessage = 'new password is too weak';

          break;
        case 'requires-recent-login':
          errormessage =
              "please sign out and sign in again before changing password";
          break;
        default:
          errormessage = 'failed to change password';
      }
      _error.value = errormessage;
      Get.snackbar(
        "Error",
        errormessage,
        backgroundColor: Colors.red.withOpacity(.1),
        colorText: Colors.red,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = "failed to change password";
      print(e.toString());
      Get.snackbar(
        "Error",
        _error.value,
        backgroundColor: Colors.red.withOpacity(.1),
        colorText: Colors.red,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isloading.value = false;
    }
  }

  String? validatecurrentpassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'please enter your current password';
    }
    return null;
  }

  String? validatenewpassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'please enter a new password';
    }
    if (value!.length < 6) {
      return " password must atleast 6 character";
    }
    if (value == currentpasswordcontroller) {
      return "new password Must be different the current password";
    }
    return null;
  }

  String? validateconfirmpassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'please confirm your password';
    }
    if (value!.length < 6) {
      return " password must atleast 6 character";
    }
    if (value == currentpasswordcontroller) {
      return "new password Must be different the current password";
    }
    return null;
  }
}
