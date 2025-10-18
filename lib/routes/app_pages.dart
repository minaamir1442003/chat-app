import 'package:chat/controllers/profile_conroller.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/views/auth/forget_password_view.dart';
import 'package:chat/views/auth/login_view.dart';
import 'package:chat/views/auth/profile_view.dart';
import 'package:chat/views/auth/register_view.dart';
import 'package:chat/views/splach_view.dart' show SplachView;
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AppPages {
  static const initial = AppRoutes.splach;

  static final routes = [
    GetPage(name: AppRoutes.splach, page: () => const SplachView()),
    GetPage(name: AppRoutes.login, page: () => const Loginview()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(
      name: AppRoutes.forgotpassword,
      page: () => const ForgetPasswordView(),
    ),

    // GetPage(name: AppRoutes.home, page: () => const Homeview(),
    //   bindings: BindingsBuilder(
    //   () {
    //     Get.put(homecontroller())
    //   },
    // )),
    // GetPage(name: AppRoutes.main, page: () => const Mainview(),
    //   bindings: BindingsBuilder(
    //   () {
    //     Get.put(maincontroller())
    //   },
    // )),
    // GetPage(name: AppRoutes.login, page: () => const Loginview()),
    // GetPage(name: AppRoutes.register, page: () => const Registerview()),
    // GetPage(name: AppRoutes.forgotpassword, page: () => const ForgotPasswordview()),
    // GetPage(name: AppRoutes.changepassword, page: () => const ChangePasswordview()),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    // GetPage(name: AppRoutes.chat, page: () => const Chatview()
    // ,  bindings: BindingsBuilder(
    //   () {
    //     Get.put(chatcontroller())
    //   },
    // )),
    // GetPage(name: AppRoutes.userlist, page: () => const UserListview(),
    //   bindings: BindingsBuilder(
    //   () {
    //     Get.put(userlistcontroller())
    //   },
    // )),
    // GetPage(name: AppRoutes.frinds, page: () => const Friendsview(),
    //   bindings: BindingsBuilder(
    //   () {
    //     Get.put(frindcontroller())
    //   },
    // )),
    // GetPage(name: AppRoutes.frindsreqire, page: () => const FriendsRequestview(

    // ),
    // bindings: BindingsBuilder(
    //   () {
    //     Get.put(frindreqirecontroll())
    //   },
    // )),
    // GetPage(name: AppRoutes.notiication, page: () => const Notificationview()),
  ];
}
