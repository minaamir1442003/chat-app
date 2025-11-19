import 'dart:async';

import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/models/frind_ship_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendController extends GetxController {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  final RxList<UserModel> _friend = <UserModel>[].obs;
  final RxBool _isloading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchquery = ''.obs;
  final RxList<UserModel> _filteredfriend = <UserModel>[].obs;
  StreamSubscription? _friendshipssubscriptions;
  List<FriendshipModel> get friendships => _friendships.toList();
  List<UserModel> get friend => _friend;
  List<UserModel> get filteredfriends => _filteredfriend;
  bool get isloading => _isloading.value;
  String get error => _error.value;
  String get searchquery => _searchquery.value;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadfriends();
    debounce(
      _searchquery,
      (_) => _fillterfriends(),
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _friendshipssubscriptions?.cancel();
  }

  void _loadfriends() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      _friendshipssubscriptions?.cancel();
      _friendshipssubscriptions = _firestoreServices
          .getfriendsstream(currentuserid)
          .listen((friendshiplist) {
            _friendships.value = friendshiplist;
            _loadfrienddetails(currentuserid, friendshiplist);
          });
    }
  }

Future<void> _loadfrienddetails(
  String currentuserid,
  List<FriendshipModel> friendshiplist,
) async {
  try {
    _isloading.value = true;
    print('👥 Loading details for ${friendshiplist.length} friendships');
    
    List<UserModel> friendusers = [];
    
    for (var friendship in friendshiplist) {
      try {
        String friendid = friendship.getotheruserid(currentuserid);
        
        // ✅ فحص إضافي لمنع الصداقة مع النفس
        if (friendid == currentuserid) {
          print('🚫 Skipping self-friendship: ${friendship.id}');
          continue;
        }
        
        print('🔍 Loading user details for: $friendid');
        
        var friend = await _firestoreServices.getuser(friendid);
        if (friend != null) {
          print('✅ Found user: ${friend.displayname}');
          friendusers.add(friend);
        } else {
          print('❌ User not found: $friendid');
        }
      } catch (e) {
        print('❌ Error loading user ${friendship.id}: $e');
      }
    }
    
    print('🎯 Total friends loaded: ${friendusers.length}');
    _friend.value = friendusers;
    _fillterfriends();
    
  } catch (e) {
    print('💥 Error in _loadfrienddetails: $e');
    _error.value = e.toString();
  } finally {
    _isloading.value = false;
  }
}

  void _fillterfriends() {
    final query = _searchquery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredfriend.value = _friend;
    } else {
      _filteredfriend.value =
          _friend.where((friend) {
            return friend.displayname.toLowerCase().contains(query) ||
                friend.email.toLowerCase().contains(query);
          }).toList();
    }
  }

  void updatesearchquery(String query) {
    _searchquery.value = query;
  }

  void cleansearch() {
    _searchquery.value = '';
  }

  Future<void> refreshfriends() async {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      _loadfriends();
    }
  }

  Future<void> removefriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Remove friend"),
          content: Text(
            "Are you sure you want to remove ${friend.displayname} from you friends?",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text("Remove"),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ],
        ),
      );
      if (result == true) {
        final currentuserid = _authController.user?.uid;
        if (currentuserid != null) {
          await _firestoreServices.removefriendship(currentuserid, friend.id);
          Get.snackbar(
            "Success",
            "${friend.displayname} has been removed from your friends.",
            backgroundColor: Colors.green.withOpacity(.1),
            colorText: Colors.green,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        "failed to remove friend ",
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
      print(e.toString());
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> blockfriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Block user"),
          content: Text(
            "are you sure you want to block ${friend.displayname}? you will no longer block",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text("Block"),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ],
        ),
      );
      if (result == true) {
        final currentuserid = _authController.user?.uid;
        if (currentuserid != null) {
          await _firestoreServices.blockeduser(currentuserid, friend.id);
          Get.snackbar(
            "Success",
            "${friend.displayname} has been blocked",
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "faild to block user",
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
      print(e.toString());
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> startchat(UserModel friend) async {
    try {
      _isloading.value = true;
      final currentuserid = _authController.user?.uid;
      if (currentuserid != null) {
        Get.toNamed(
          AppRoutes.chat,
          arguments: {"chatid": null, "otheruser": friend, "isnewchat": true},
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "failled to start chat",
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
      print(e.toString());
    } finally {
      _isloading.value = false;
    }
  }

  String getlastseentext(UserModel user) {
    if (user.isonline) {
      return 'online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastseen);
      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inHours < 1) {
        return 'last seen ${difference.inMinutes} m ago';
      } else if (difference.inDays < 1) {
        return 'last seen ${difference.inHours} h ago';
      } else if (difference.inDays < 7) {
        return 'last seen ${difference.inHours} d ago';
      } else {
        return 'last seen ${user.lastseen.day}/${user.lastseen.month}/${user.lastseen.year}';
      }
    }
  }

  void openfriendrequests() {
    Get.toNamed(AppRoutes.frindsrequests);
  }

  void clearerror() {
    _error.value = '';
  }
}
