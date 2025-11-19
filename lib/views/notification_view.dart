import 'package:chat/controllers/notification_controller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:chat/views/widget/notificationitem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationView extends GetView<NotificationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          Obx(() {
            final unreadCount = controller.getunreadcount();
            return unreadCount > 0
                ? TextButton(
                  onPressed: controller.markallasread,
                  child: Text("Mark all as read"),
                )
                : SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return _buildemptystate();
        }
        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final user =
                notification.data['senderId'] != null
                    ? controller.getuser(notification.data['senderId'])
                    : notification.data["userId"] != null
                    ? controller.getuser(notification.data["userId"])
                    : null;
            return Notificationitem(
              notification: notification,
              user: user,

              timetext: controller.getnotificationtimetext(
                notification.createdAt,
              ),
              icon: controller.getnotificationicon(notification.type),
              iconcolor: controller.getnotificationcolor(notification.type),

              ontap: () => controller.handlenotificationtap(notification),
              ondelete: () => controller.deletenotification(notification),
            );
          },
        );
      }),
    );
  }

  Widget _buildemptystate() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primecolor.withOpacity(.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 50,
                color: AppTheme.primecolor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "No Notifications",
              style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textprimarycolor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'when you receive friend requests, messages, or other updates, they will appear here.',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textsecondrycolor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
