import 'package:chat/controllers/profile_conroller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class MainController extends GetxController {
  final RxInt _currentindex = 0.obs;
  final PageController pageController = PageController();
  int get currentindex => _currentindex.value;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // Get.lazyPut(() => homecontroller());
    // Get.lazyPut(() => friendscontroller());

    // Get.lazyPut(() => userslistcontroller());

    Get.lazyPut(() => ProfileController());
  }

  @override
  void onClose() {
    pageController.dispose();
    // TODO: implement onClose
    super.onClose();
  }

  void changetabindex(int index) {
    _currentindex.value = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onpagechanged(int index) {
    _currentindex.value = index;
  }

  int getunreadcount() {
    try {
      // final homecontroller = Get.find<HomeController>();
      // return homecontroller.gettotalunreadcount();
      return 5;
    } catch (e) {
      return 0;
    }
  }

  int getnotificationcount() {
    try {
      // final homecontroller = Get.find<HomeController>();
      // return homecontroller.getunreadnotificationscount();
      return 7;
    } catch (e) {
      return 0;
    }
  }
}
