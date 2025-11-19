import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/controllers/home_controller.dart';
import 'package:chat/models/chat_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final UserModel otheruser;
  final String lastmessagetime;
  final VoidCallback ontap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.otheruser,
    required this.lastmessagetime,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final HomeController homeController = Get.find<HomeController>();
    final currentuserid = authController.user?.uid ?? '';
    final unreadcount = chat.getunreadcount(currentuserid);
    return Card(
      child: InkWell(
        onTap: ontap,
        onLongPress: () => _showchatoptions(context, homeController),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primecolor,
                    child:
                        otheruser.photourl.isNotEmpty
                            ? ClipOval(
                              child: Image.network(
                                otheruser.photourl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    otheruser.displayname.isNotEmpty
                                        ? otheruser.displayname[0].toUpperCase()
                                        : "?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            )
                            : Text(
                              otheruser.displayname.isNotEmpty
                                  ? otheruser.displayname[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  if (otheruser.isonline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.succescolor,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otheruser.displayname,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight:
                                  unreadcount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastmessagetime.isNotEmpty)
                          Text(
                            lastmessagetime,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  unreadcount > 0
                                      ? AppTheme.primecolor
                                      : AppTheme.textsecondrycolor,
                              fontWeight:
                                  unreadcount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (chat.lastMessageSenderId ==
                                  currentuserid) ...[
                                Icon(
                                  _getseenstatusicon(),
                                  size: 14,
                                  color: _getseenstatuscolor(),
                                ),
                                SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  chat.lastMessage ?? 'no message yet',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color:
                                        unreadcount > 0
                                            ? AppTheme.primecolor
                                            : AppTheme.textsecondrycolor,
                                    fontWeight:
                                        unreadcount > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unreadcount > 0) ...[
                          SizedBox(width: 8),
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primecolor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadcount > 99 ? '99+' : unreadcount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (chat.lastMessageSenderId == currentuserid) ...[
                      SizedBox(height: 2),
                      Text(
                        _getseenstatustext(),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: _getseenstatuscolor(),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getseenstatusicon() {
    final AuthController authcontroller = Get.find<AuthController>();
    final currentuserid = authcontroller.user?.uid ?? '';
    final otheruserid = chat.getotherparticipant(currentuserid);
    if (chat.ismessageseen(currentuserid, otheruserid)) {
      return Icons.done_all;
    } else {
      return Icons.done;
    }
  }

  Color _getseenstatuscolor() {
    final AuthController authcontroller = Get.find<AuthController>();
    final currentuserid = authcontroller.user?.uid ?? '';
    final otheruserid = chat.getotherparticipant(currentuserid);
    if (chat.ismessageseen(currentuserid, otheruserid)) {
      return AppTheme.primecolor;
    } else {
      return AppTheme.textsecondrycolor;
    }
  }

  String _getseenstatustext() {
    final AuthController authcontroller = Get.find<AuthController>();
    final currentuserid = authcontroller.user?.uid ?? '';
    final otheruserid = chat.getotherparticipant(currentuserid);
    if (chat.ismessageseen(currentuserid, otheruserid)) {
      return 'Seen';
    } else {
      return 'Delivered';
    }
  }

  void _showchatoptions(BuildContext context, HomeController homecontroller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardcolor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textsecondrycolor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppTheme.errorcolor),
              title: Text("Delete chat"),
              subtitle: Text("this will delet that chat for you only"),
              onTap: () {
                Get.back();
                homecontroller.deletchat(chat);
              },
            ),
            SizedBox(height: 10,),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppTheme.errorcolor),
              title: Text("Delete chat"),
              subtitle: Text("this will delet that chat for you only"),
              onTap: () {
                Get.back();
                homecontroller.deletchat(chat);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: AppTheme.primecolor),
              title: Text("View profile"),
              onTap: () {
                Get.back();
              },
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
