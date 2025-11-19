import 'package:chat/controllers/friend_request_controller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:chat/views/widget/friend_request_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class FriendRequestView extends GetView<FriendRequestController> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("friend requests"),
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardcolor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bordercolor),
            ),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changetab(0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedtabindex == 0
                                  ? AppTheme.primecolor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              color:
                                  controller.selectedtabindex == 0
                                      ? Colors.white
                                      : AppTheme.textsecondrycolor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Received {${controller.receivedrequests.length}}",
                              style: TextStyle(
                                color:
                                    controller.selectedtabindex == 0
                                        ? Colors.white
                                        : AppTheme.textsecondrycolor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changetab(1),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedtabindex == 1
                                  ? AppTheme.primecolor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              color:
                                  controller.selectedtabindex == 1
                                      ? Colors.white
                                      : AppTheme.textsecondrycolor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Sent {${controller.sentrequests.length}}",
                              style: TextStyle(
                                color:
                                    controller.selectedtabindex == 1
                                        ? Colors.white
                                        : AppTheme.textsecondrycolor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: controller.selectedtabindex,
                children: [_buildreceivedrequststab(), _buildsentrequeststab()],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildsentrequeststab() {
    return Obx(() {
      if (controller.sentrequests.isEmpty) {
        return _buildemptystate(
          icon: Icons.inbox_outlined,
          title: "no sent requests ",
          message: "friend requests you send will appear here",
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: controller.sentrequests.length,
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          final request = controller.sentrequests[index];
          final recever = controller.getuser(request.receiverId);
          if (recever == null) {
            return SizedBox.shrink();
          }
          return FriendRequestItem(
            request: request,
            user: recever,
            timetext: controller.getrequesttimetext(request.createdAt),
            isreceived: false,
            statustext: controller.getstatustext(request.status),
            statuscolor: controller.getstatuscolor(request.status),
          );
        },
      );
    });
  }

  Widget _buildreceivedrequststab() {
    return Obx(() {
      if (controller.receivedrequests.isEmpty) {
        return _buildemptystate(
          icon: Icons.inbox_outlined,
          title: "no friend requests ",
          message:
              "when someone sends  you friend request, it will appear here.",
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: controller.receivedrequests.length,
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          final request = controller.receivedrequests[index];
          final sender = controller.getuser(request.senderId);
          if (sender == null) {
            return SizedBox.shrink();
          }
          return FriendRequestItem(
            request: request,
            user: sender,
            timetext: controller.getrequesttimetext(request.createdAt),
            isreceived: true,
            onaccept: () => controller.acceptrequest(request),
            ondecline: () => controller.declinefriendrequest(request),
          );
        },
      );
    });
  }

  Widget _buildemptystate({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primecolor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, size: 50, color: AppTheme.primecolor),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textprimarycolor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: Get.textTheme.bodyMedium?.copyWith(
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
