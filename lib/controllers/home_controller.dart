import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/models/chat_model.dart';
import 'package:chat/models/notification_moodel.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirestoreServices _firestoreservece = FirestoreServices();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<ChatModel> _allchat = <ChatModel>[].obs;
  final RxList<ChatModel> _filteredchats = <ChatModel>[].obs;
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isloading = false.obs;
  final RxString _error = ''.obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;
  final RxString _searchquery = ''.obs;
  final RxBool _issearching = false.obs;
  final RxString _activefilter = 'all'.obs;
  List<ChatModel> get chats => _getfilteredchats();
  List<ChatModel> get allchats => _allchat;
  List<ChatModel> get filteredchats => _filteredchats;
  List<NotificationModel> get notifications => _notifications;
  bool get isloading => _isloading.value;
  String get error => _error.value;
  String get searchquery => _searchquery.value;
  bool get issearching => _issearching.value;
  String get activefilter => _activefilter.value;
  Map<String, UserModel> get users => _users;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadchats();
    _loadusers();
    _loadnotifications();
  }

  void _loadchats() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      _allchat.bindStream(_firestoreservece.getuserchatsstream(currentuserid));
      ever(_allchat, (_) {
        if (_issearching.value && _searchquery.value.isNotEmpty) {
          _performsearch(_searchquery.value);
        }
      });
      ever(_activefilter, (_) {
        if (_searchquery.value.isNotEmpty) {
          _performsearch(_searchquery.value);
        }
      });
    }
  }

  void _loadusers() {
    _users.bindStream(
      _firestoreservece.getallusersstream().map((userlist) {
        Map<String, UserModel> usermap = {};
        for (var user in userlist) {
          usermap[user.id] = user;
        }
        return usermap;
      }),
    );
  }

  void _loadnotifications() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      _notifications.bindStream(
        _firestoreservece.getnotificationsstram(currentuserid),
      );
    }
  }

  UserModel? getotheruser(ChatModel chat) {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      final otheruserid = chat.getotherparticipant(currentuserid);
      return _users[otheruserid];
    }
    return null;
  }

  String formatlastmessagetime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) {
      return "just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }

  List<ChatModel> _getfilteredchats() {
    List<ChatModel> baselist = _issearching.value ? _filteredchats : _allchat;
    switch (_activefilter.value) {
      case "unread":
        return _applyunreadfilter(baselist);
      case "recent":
        return _applyrecentfilter(baselist);
      case "active":
        return _applyactivefilter(baselist);
      case "all":
      default:
        return baselist;
    }
  }

  List<ChatModel> _applyunreadfilter(List<ChatModel> chats) {
    final currentuserid = _authController.user?.uid;
    if (currentuserid == null) return [];
    return chats
        .where((chat) => chat.getunreadcount(currentuserid) > 0)
        .toList();
  }

  List<ChatModel> _applyrecentfilter(List<ChatModel> chats) {
    final now = DateTime.now();
    final threedayago = now.subtract(Duration(days: 3));
    return chats.where((chat) {
      if (chat.lastMessageTime == null) return false;
      return chat.lastMessageTime!.isAfter(threedayago);
    }).toList();
  }

  List<ChatModel> _applyactivefilter(List<ChatModel> chats) {
    final now = DateTime.now();
    final oneweekago = now.subtract(Duration(days: 3));
    return chats.where((chat) {
      if (chat.lastMessageTime == null) return false;
      return chat.lastMessageTime!.isAfter(oneweekago);
    }).toList();
  }

  void setfilter(String filtertype) {
    _activefilter.value = filtertype;
    if (filtertype == 'all') {
      if (_searchquery.value.isEmpty) {
        _issearching.value = false;
        _filteredchats.clear();
      }
    }
  }

  void clearallfilters() {
    _activefilter.value = 'all';
    _clearsearch();
  }

  void onsearchchanged(String query) {
    _searchquery.value = query;
    if (query.isEmpty) {
      _clearsearch();
    } else {
      _issearching.value = true;
      _performsearch(query);
    }
  }

  void _performsearch(String query) {
    final lowercasequery = query.toLowerCase().trim();
    _filteredchats.value =
        _allchat.where((chat) {
          final otheruser = getotheruser(chat);
          if (otheruser == null) return false;
          final displaynamematch =
              otheruser.displayname.toLowerCase().contains(lowercasequery) ??
              false;
          final emailmatch =
              otheruser.email.toLowerCase().contains(lowercasequery) ?? false;
          final lastmessagematch =
              chat.lastMessage?.toLowerCase().contains(lowercasequery) ?? false;
          return displaynamematch || emailmatch || lastmessagematch;
        }).toList();
    _sortsearchresults(lowercasequery);
  }

  void _sortsearchresults(String query) {
    filteredchats.sort((a, b) {
      final usera = getotheruser(a);
      final userb = getotheruser(b);
      if (usera == null || userb == null) return 0;
      final exactmatcha =
          usera.displayname.toLowerCase().startsWith(query) ?? false;
      final exactmatchb =
          userb.displayname.toLowerCase().startsWith(query) ?? false;
      if (exactmatcha && !exactmatchb) return -1;
      if (!exactmatcha && exactmatchb) return 1;
      return (b.lastMessageTime ?? DateTime(0)).compareTo(
        a.lastMessageTime ?? DateTime(0),
      );
    });
  }

  void _clearsearch() {
    _issearching.value = false;
    _filteredchats.clear();
  }

  void clearsearch() {
    _searchquery.value = '';
    _clearsearch();
  }

  void searchuserbyname(String name) {
    onsearchchanged(name);
  }

  void searchbylastmessage(String message) {
    onsearchchanged(message);
  }

  List<ChatModel> getunreadchats() {
    return _applyunreadfilter(chats);
  }

  List<ChatModel> getactivechat() {
    return _applyactivefilter(chats);
  }

  List<ChatModel> getrecentchats({int limit = 10}) {
    final recentchats = _applyrecentfilter(_allchat);
    final sortedchats = List<ChatModel>.from(recentchats);
    sortedchats.sort((a, b) {
      return (b.lastMessageTime ?? DateTime(0)).compareTo(
        a.lastMessageTime ?? DateTime(0),
      );
    });
    return sortedchats.take(limit).toList();
  }

  int getunreadcount() {
    return getunreadchats().length;
  }

  int getrecentcount() {
    return _applyrecentfilter(_allchat).length;
  }

  int getactivecount() {
    return getactivechat().length;
  }

  List<String> getsearchsuggestions() {
    final suggestions = <String>[];
    for (var chat in _allchat) {
      final otheruser = getotheruser(chat);
      if (otheruser?.displayname != null) {
        suggestions.add(otheruser!.displayname);
      }
    }
    return suggestions.toSet().toList();
  }

  void openchat(ChatModel chat) {
    final otheruser = getotheruser(chat);
    if (otheruser != null) {
      Get.toNamed(
        AppRoutes.chat,
        arguments: {'chatid': chat.id, 'otheruser': otheruser},
      );
    }
  }

  void openfriends() {
    Get.toNamed(AppRoutes.frinds);
  }

  void opennotifications() {
    Get.toNamed(AppRoutes.notiication);
  }

  Future<void> refrechchat() async {
    _isloading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
      if (_issearching.value && _searchquery.value.isNotEmpty) {
        _performsearch(_searchquery.value);
      }
    } catch (e) {
      _error.value = "failed to refresh chat";
      print(e.toString());
    } finally {
      _isloading.value = false;
    }
  }

  int gettotalunreadcount() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid == null) return 0;
    int total = 0;
    for (var chat in _allchat) {
      total = chat.getunreadcount(currentuserid);
    }
    return total;
  }

  int getunreadnotificationcount() {
    return _notifications.where((notif) => !notif.isRead).length;
  }

  Future<void> deletchat(ChatModel chat) async {
    try {
      final currentuserid = _authController.user?.uid;
      if (currentuserid == null) return;
      final otheruser = getotheruser(chat);
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("delet chat"),
          content: Text(
            "are you sure you want to delet the chat with ${otheruser?.displayname ?? 'this user'}",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text("cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text("delet", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (result == true) {
        await _firestoreservece.deletechatforuser(chat.id, currentuserid);
        Get.snackbar("success", "chat deleted ");
      }
    } catch (e) {
      Get.snackbar("Error", "failed to deleted chat ");
      print(e.toString());
    } finally {
      _isloading.value = false;
    }
  }

  void clearerror() {
    _error.value = '';
  }
  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    
  }
}
