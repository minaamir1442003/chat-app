import 'package:chat/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/state_manager.dart';

class ForgetPasswordController extends GetxController {
  final AuthServices _authServices = AuthServices();
  final TextEditingController emailcontroller = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final RxBool _isloading = false.obs;
  final RxString _error = "".obs;
  final RxBool _emailsend = false.obs;
  bool get isloading => _isloading.value;
  String get error => _error.value;
  bool get emailsend => _emailsend.value;
  @override
  void onClose() {
    emailcontroller.dispose();
    super.onClose();
  }

  Future<void> sendpasswordreset() async {
    if (!formkey.currentState!.validate()) return;
    try {
      _isloading.value = true;
      _error.value = "";
      await _authServices.sendPasswordReset(emailcontroller.text.trim());
      _emailsend.value = true;
      Get.snackbar(
        "success",
        "password resent email send to ${emailcontroller.text}",
        backgroundColor: Colors.green.withOpacity(.1),
        colorText: Colors.green,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        "error",
        e.toString(),
        backgroundColor: Colors.redAccent.withOpacity(.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isloading.value = false;
    }
  }

  void gobacktologin() {
    Get.back();
  }

  void resentemail() {
    _emailsend.value = false;
    sendpasswordreset();
  }

  String? validareemail(String? value) {
    if (value?.isEmpty ?? true) {
      return "please enter your email";
    }
    if (!GetUtils.isEmail(value!)) {  
    return "Please enter a valid email";
  }
    return null;
  }

  void _clearerror() {
    _error.value = '';
  }
}
