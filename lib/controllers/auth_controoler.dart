import 'package:chat/models/user_model.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart' show Rx;

class AuthController extends GetxController {
  final AuthServices _authServices = AuthServices();

  final Rx<User?> _user = Rx<User?>(null);

  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);

  final RxBool _isloading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isinitialized = false.obs;
  User? get user => _user.value;
  UserModel? get usermodel => _userModel.value;
  bool get isloading => _isloading.value;
  String get error => _error.value;
  bool get isauthenticated => _user.value != null;
  bool get isinitialized => _isinitialized.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authServices.authstateChanges);
    // ever(_user, _handelauthchange);
  }

  // void _handelauthchange(User? usrer) {
  //   if (user == null) {
  //     if (Get.currentRoute != AppRoutes.login) {
  //       Get.offAllNamed(AppRoutes.login);
  //     }
  //   } else {
  //     if (Get.currentRoute != AppRoutes.profile) {
  //       Get.offAllNamed(AppRoutes.profile);
  //     }
  //   }
  //   if (!_isinitialized.value) {
  //     _isinitialized.value = true;
  //   }
  // }

  // void checkinitialauthstate() {
  //   final currentuser = FirebaseAuth.instance.currentUser;
  //   if (currentuser != null) {
  //     _user.value = currentuser;
  //     Get.offAllNamed(AppRoutes.main);
  //   } else {
  //     Get.offAllNamed(AppRoutes.login);
  //   }
  //   _isinitialized.value = true;
  // }

  Future<void> signinwithemailandpassword(String email, String password) async {
    try {
      _isloading.value = true;
      _error.value = "";
      UserModel? usrmodel = await _authServices.signinwithemailandpassword(
        email,
        password,
      );
      if (usrmodel != null) {
        _userModel.value = usermodel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("error", 'faild to login');
      print(e);
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> registerwithemailandpassword(
    String email,
    String password,
    String displayname,
  ) async {
    try {
      _isloading.value = true;
      _error.value = "";
      UserModel? usrmodel = await _authServices.registerwithemailandpassword(
        email,
        password,
        displayname,
      );
      if (usrmodel != null) {
        _userModel.value = usermodel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("error", 'faild to creat acount');
      print(e);
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> signout() async {
    try {
      _isloading.value = true;
      await _authServices.signout();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("error", "fiald to signout");
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> deletacount() async {
    try {
      _isloading.value = true;
      await _authServices.deletacount();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("Error", "fiald to delet account");
    } finally {
      _isloading.value = false;
    }
  }

  void clearerror() {
    _error.value = "";
  }
}
