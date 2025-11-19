import 'package:chat/models/notification_moodel.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';

class Notificationitem extends StatelessWidget {
  final NotificationModel notification;
  final UserModel? user;
  final String timetext;
  final IconData icon;
  final Color iconcolor;
  final VoidCallback ontap;
  final VoidCallback ondelete;
  const Notificationitem({
    super.key,
    required this.notification,
    this.user,
    required this.timetext,
    required this.icon,
    required this.iconcolor,
    required this.ontap,
    required this.ondelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead ? null : AppTheme.primecolor.withOpacity(.05),
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconcolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: iconcolor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primecolor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getnotificationbody(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textsecondrycolor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      timetext,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textsecondrycolor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: ondelete,
                icon: Icon(
                  Icons.close,
                  color: AppTheme.textsecondrycolor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getnotificationbody() {
    String body = notification.body;
    if (user != null) {
      switch (notification.type) {
        case NotificationType.friendRequest:
          body = '${user!.displayname} sent you a friend request.';
          break;
        case NotificationType.friendRequestAccepted:
          body = '${user!.displayname} accepted your friend request.';
          break;
        case NotificationType.friendRequestDeclined:
          body = '${user!.displayname} declined your friend request.';
          break;
        case NotificationType.newMessage:
          body = '${user!.displayname} sent you a newmessage';
          break;
        case NotificationType.friendRemoved:
          body = 'you are no longer friend with ${user!.displayname}';
          break;
      }
    }
    return body;
  }
}
