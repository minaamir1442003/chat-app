import 'package:chat/controllers/main_controller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:chat/views/auth/profile/profile_view.dart';
import 'package:chat/views/find_people_view.dart';
import 'package:chat/views/home_view.dart';
import 'package:chat/views/widget/friend_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainView extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onpagechanged,
        children: [
          HomeView(),
          FriendView(),
          FindPeopleView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentindex,
          onTap: controller.changetabindex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primecolor,
          unselectedItemColor: AppTheme.textsecondrycolor,
          backgroundColor: Colors.white,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: _buildiconwithbadge(
                Icons.chat_outlined,
                controller.getunreadcount(),
              ),
              activeIcon: _buildiconwithbadge(
                Icons.chat,
                controller.getunreadcount(),
              ),
              label: 'chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search_outlined),
              activeIcon: Icon(Icons.person_search),
              label: 'find friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: 'profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildiconwithbadge(IconData icon, int count) {
    return Stack(
      children: [
        Icon(icon),
        if(count>0)
        Positioned(right: 0,top: 0,
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppTheme.errorcolor,
            borderRadius: BorderRadius.circular(6)
          ),
          constraints: BoxConstraints(minWidth: 12,minHeight: 12),
          child: Text(
            count> 99 ? '99+':count.toString(),
            style: TextStyle(
              color: Colors.white,fontSize: 8
            ),
            textAlign: TextAlign.center,
          ),
        ),)
      ],
    );
  }
}
