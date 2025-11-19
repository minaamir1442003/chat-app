import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/models/notification_moodel.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/services/firestore_services.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirestoreServices _firestoreservece = FirestoreServices();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxMap<String, UserModel> _user = <String, UserModel>{}.obs;
  final RxBool _isloading = false.obs;
  final RxString _error = ''.obs;
  List<NotificationModel> get notifications => _notifications;
  Map<String, UserModel> get user => _user;
  bool get isloading => _isloading.value;
  String get error => _error.value;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadnotifications();
    _loadusers();
  }

  void _loadnotifications() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      _notifications.bindStream(
        _firestoreservece.getnotificationsstram(currentuserid),
      );
    }
  }

  void _loadusers() {
    _user.bindStream(
      _firestoreservece.getallusersstream().map((userlist) {
        Map<String, UserModel> usermap = {};
        for (var user in userlist) {
          usermap[user.id] = user;
        }
        return usermap;
      }),
    );
  }

  UserModel? getuser(String userid) {
    return _user[userid];
  }

  Future<void> markasread(NotificationModel notifications) async {
    try {
      if (!notifications.isRead) {
        await _firestoreservece.marknotificationasread(notifications.id);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'failed to mark  as read');
      print(e.toString());
    }
  }

  Future<void> markallasread() async {
    try {
      _isloading.value = true;
      final currentuserid = _authController.user?.uid;
      if (currentuserid != null) {
        await _firestoreservece.markallnotificationsasread(currentuserid);
        Get.snackbar('success', 'All notifications marked as read');
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'failed to mark all as read');
      print(e.toString());
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> deletenotification(NotificationModel notification) async {
    try {
      await _firestoreservece.deletnotification(notification.id);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'failed to delet notification');
      print(e.toString());
    }
  }

  void handlenotificationtap(NotificationModel notification) {
    markasread(notification);
    switch (notification.type) {
      case NotificationType.friendRequest:
        Get.toNamed(AppRoutes.frindsrequests);
        break;
      case NotificationType.friendRequestAccepted:
      case NotificationType.friendRequestDeclined:
        Get.toNamed(AppRoutes.frinds);
        break;
      case NotificationType.newMessage:
        final userid = notification.data['userId'];
        if (userid != null) {
          final user = getuser(userid);
          if (user != null) {
            Get.toNamed(AppRoutes.chat, arguments: {'otheruser': user});
          }
        }
        break;
      case NotificationType.friendRemoved:
        break;
    }
  }

  String getnotificationtimetext(DateTime creadetat) {
    final now = DateTime.now();
    final difference = now.difference(creadetat);
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inHours} d ago';
    } else {
      return '${creadetat.day}/${creadetat.month}/${creadetat.year}';
    }
  }

  IconData getnotificationicon(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendRequestAccepted:
        return Icons.check_circle;
      case NotificationType.friendRequestDeclined:
        return Icons.cancel;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.friendRemoved:
        return Icons.person_remove;
    }
  }

  Color getnotificationcolor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return AppTheme.primecolor;
      case NotificationType.friendRequestAccepted:
        return AppTheme.succescolor;
      case NotificationType.friendRequestDeclined:
        return AppTheme.errorcolor;
      case NotificationType.newMessage:
        return AppTheme.secondrycolor;
      case NotificationType.friendRemoved:
        return AppTheme.errorcolor;
    }
  }

  int getunreadcount() {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  void clearerror() {
    _error.value = '';
  }
}
