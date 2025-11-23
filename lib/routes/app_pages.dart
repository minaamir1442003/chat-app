import 'package:chat/controllers/chat_conroller.dart';
import 'package:chat/controllers/friend_controller.dart';
import 'package:chat/controllers/friend_request_controller.dart';
import 'package:chat/controllers/home_controller.dart';
import 'package:chat/controllers/main_controller.dart';
import 'package:chat/controllers/notification_controller.dart';
import 'package:chat/controllers/profile_conroller.dart';
import 'package:chat/controllers/users_list_controller.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/views/auth/forget_password_view.dart';
import 'package:chat/views/auth/login_view.dart';
import 'package:chat/views/auth/profile/change_password_view.dart';
import 'package:chat/views/auth/profile/profile_view.dart';
import 'package:chat/views/auth/register_view.dart';
import 'package:chat/views/chat_view.dart';
import 'package:chat/views/find_people_view.dart';
import 'package:chat/views/friend_request_view.dart';
import 'package:chat/views/home_view.dart';
import 'package:chat/views/main_view.dart';
import 'package:chat/views/notification_view.dart';
import 'package:chat/views/splach_view.dart' show SplachView;
import 'package:chat/views/widget/friend_view.dart';
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
    GetPage(
      name: AppRoutes.changepassword,
      page: () => const ChangePasswordView(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => MainView(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
      }),
    ),
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
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: BindingsBuilder(() {
        Get.put(ChatConroller());
      }),
    ),
    GetPage(
      name: AppRoutes.userlist,
      page: () => FindPeopleView(),
      binding: BindingsBuilder(() {
        Get.put(UsersListController());
      }),
    ),
    GetPage(
      name: AppRoutes.frinds,
      page: () => FriendView(),
      binding: BindingsBuilder(() {
        Get.put(FriendController());
      }),
    ),
    GetPage(
      name: AppRoutes.frindsrequests,
      page: () => FriendRequestView(),
      binding: BindingsBuilder(() {
        Get.put(FriendRequestController());
      }),
    ),
    GetPage(
      name: AppRoutes.notiication,
      page: () => NotificationView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationController());
      }),
    ),
  ];
}
