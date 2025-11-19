import 'package:chat/controllers/users_list_controller.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListItem extends StatelessWidget {
  final UserModel users;
  final VoidCallback ontap;
  final UsersListController controller;
  const UserListItem({
    super.key,
    required this.controller,
    required this.ontap,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final relationshipstatus = controller.getuserrelationshipstats(users.id);
      if (relationshipstatus == Usererlationshipstatus.friends) {
        return SizedBox.shrink();
      }
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primecolor,
                child: Text(
                  users.displayname.isNotEmpty
                      ? users.displayname[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      users.displayname,
                      style: Theme.of(Get.context!).textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      users.email,
                      style: Theme.of(Get.context!).textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textsecondrycolor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(children: [_buildactionbutton(relationshipstatus),
              if(relationshipstatus == Usererlationshipstatus.friendrequestreceived)...
              [
                SizedBox(height: 4,),
                OutlinedButton.icon(onPressed: () => controller.declinefriendrequest(users),
                 label: Text('decline',style: TextStyle(fontSize: 15),),
                 icon: Icon(Icons.close,size: 15,),
                 style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorcolor
                 ,
                 side: BorderSide(color: AppTheme.errorcolor),
                 padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 4
                 ),
                 minimumSize: Size(0,4)
                 ),
                
                )
              ]]),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildactionbutton(Usererlationshipstatus relationshipstatus) {
    switch (relationshipstatus) {
      case Usererlationshipstatus.none:
        return ElevatedButton.icon(
          onPressed: () => controller.handelrelationshipaction(users),
          icon: Icon(controller.getrelationshipicon(relationshipstatus)),
          label: Text(controller.getrelationshipbuttontext(relationshipstatus)),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getrelationshipcolor(
              relationshipstatus,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            minimumSize: Size(0, 32),
          ),
        );
      case Usererlationshipstatus.friendrequestsent:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: controller
                    .getrelationshipcolor(relationshipstatus)
                    .withOpacity(.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.getrelationshipcolor(relationshipstatus),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getrelationshipicon(relationshipstatus),
                    color: controller.getrelationshipcolor(relationshipstatus),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    controller.getrelationshipbuttontext(relationshipstatus),
                    style: TextStyle(
                      color: controller.getrelationshipcolor(
                        relationshipstatus,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showcancelrequestsdialog(),
              icon: Icon(Icons.cancel_outlined, size: 14),
              label: Text('cancel', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                minimumSize: Size(0, 24),
              ),
            ),
          ],
        );
      case Usererlationshipstatus.friendrequestreceived:
        return ElevatedButton.icon(
          onPressed: () => controller.handelrelationshipaction(users),
          icon: Icon(controller.getrelationshipicon(relationshipstatus)),
          label: Text(controller.getrelationshipbuttontext(relationshipstatus)),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getrelationshipcolor(
              relationshipstatus,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            minimumSize: Size(0, 32),
          ),
        );
      case Usererlationshipstatus.blocked:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.errorcolor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: AppTheme.errorcolor, size: 16),
              SizedBox(width: 4),
              Text(
                'Blocked',
                style: TextStyle(
                  color: AppTheme.errorcolor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case Usererlationshipstatus.friends:
        return SizedBox.shrink();
    }
  }

  void _showcancelrequestsdialog() {
    Get.dialog(
      AlertDialog(
        title: Text('cancel friend request'),
        content: Text(
          'are you sure you want to cancel the friend request to ${users.displayname}',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("keep request")),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelfriendrequest(users);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent
            ),
            child: Text('cancel request'),
          ),
        ],
      ),
    );
  }
}
