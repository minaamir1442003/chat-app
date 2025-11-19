import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/models/frind_reqist_state.dart';
import 'package:chat/models/frind_ship_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

enum Usererlationshipstatus {
  none,
  friendrequestsent,
  friendrequestreceived,
  friends,
  blocked,
}

class UsersListController extends GetxController {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final AuthController _authController = Get.find<AuthController>();

  final Uuid _uuid = Uuid();
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredusers = <UserModel>[].obs;
  final RxBool _isloading = false.obs;
  final RxString _searchquery = ''.obs;
  final RxString _error = ''.obs;
  final RxMap<String, Usererlationshipstatus> _userrelationships =
      <String, Usererlationshipstatus>{}.obs;
  final RxList<FrindReqistModel> _setrequests = <FrindReqistModel>[].obs;
  final RxList<FrindReqistModel> _receivedrequests = <FrindReqistModel>[].obs;
  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  List<UserModel> get users => _users;
  List<UserModel> get filteredusers => _filteredusers;
  bool get isloading => _isloading.value;
  String get searchquery => _searchquery.value;
  String get error => _error.value;
  Map<String, Usererlationshipstatus> get userrelationships =>
      _userrelationships;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadusers();
    _loadrelationships();
    debounce(
      _setrequests,
      (_) => _filterusers(),
      time: Duration(milliseconds: 300),
    );
  }

  void _loadusers() async {
    _users.bindStream(_firestoreServices.getallusersstream());
    ever(_users, (List<UserModel> userlist) {
      final currentuserid = _authController.user?.uid;
      final otherusers =
          userlist.where((user) => user.id != currentuserid).toList();
      if (_searchquery.isEmpty) {
        _filteredusers.value = otherusers;
      } else {
        _filterusers();
      }
    });
  }

  void _loadrelationships() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null) {
      //load  sent friend
      _setrequests.bindStream(
        _firestoreServices.getsentfriendrequestsstream(currentuserid),
      );
      //load received friend requests
      _receivedrequests.bindStream(
        _firestoreServices.getfriendrequeststream(currentuserid),
      );
      //load friends/friendships
      _friendships.bindStream(
        _firestoreServices.getfriendsstream(currentuserid),
      );
      ever(_setrequests, (_) => _updateallrelatiosshipsstate());
      ever(_receivedrequests, (_) => _updateallrelatiosshipsstate());
      ever(_friendships, (_) => _updateallrelatiosshipsstate());
      ever(_users, (_) => _updateallrelatiosshipsstate());
    }
  }

  void _updateallrelatiosshipsstate() {
    final currentuserid = _authController.user?.uid;
    if (currentuserid == null) return;
    for (var user in _users) {
      if (user.id != currentuserid) {
        final status = _calculateuserrelationshipstatus(user.id);
        _userrelationships[user.id] = status;
      }
    }
  }

  Usererlationshipstatus _calculateuserrelationshipstatus(String userid) {
    final currentuserid = _authController.user?.uid;
    if (currentuserid == null) return Usererlationshipstatus.none;
    final friendship = _friendships.firstWhereOrNull(
      (f) =>
          (f.user1Id == currentuserid && f.user2Id == userid) ||
          (f.user1Id == userid && f.user2Id == currentuserid),
    );
    if (friendship != null) {
      if (friendship.isBlocked) {
        return Usererlationshipstatus.blocked;
      } else {
        return Usererlationshipstatus.friends;
      }
    }
    final sentrequest = _setrequests.firstWhereOrNull(
      (r) => r.receiverId == userid && r.status == FrindReqistState.pending,
    );
    if (sentrequest != null) {
      return Usererlationshipstatus.friendrequestsent;
    }
    final receiverrequest = _receivedrequests.firstWhereOrNull(
      (r) => r.senderId == userid && r.status == FrindReqistState.pending,
    );
    if (receiverrequest != null) {
      return Usererlationshipstatus.friendrequestreceived;
    }
    return Usererlationshipstatus.none;
  }

  void _filterusers() {
    final currentuserid = _authController.user?.uid;
    final query = _searchquery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredusers.value =
          _users.where((user) => user.id != currentuserid).toList();
    } else {
      _filteredusers.value =
          _users.where((user) {
            return user.id != currentuserid &&
                (user.displayname.toLowerCase().contains(query) ||
                    user.email.toLowerCase().contains(query));
          }).toList();
    }
  }

  void updatesearchquery(String query) {
    _searchquery.value = query;
  }

  void clearsearch() {
    _searchquery.value = '';
  }

  Future<void> sendfriendrequests(UserModel user) async {
    try {
      _isloading.value = true;

      final currentuserid = _authController.user?.uid;
      print('Current user ID: ${_authController.user?.uid}');

      if (currentuserid != null) {
        final request = FrindReqistModel(
          id: _uuid.v4(),
          senderId: currentuserid,
          receiverId: user.id,
          createdAt: DateTime.now(),
        );

        _userrelationships[user.id] = Usererlationshipstatus.friendrequestsent;
        _userrelationships.refresh();
        await _firestoreServices.sendfrindrequest(request);
        Get.snackbar('success', 'friend request sent to ${user.displayname}');
      }
    } catch (e) {
      _userrelationships[user.id] = Usererlationshipstatus.none;
      _error.value = e.toString();
      print('error sending friend requests: $e');
      Get.snackbar('Error', 'failed to send friend requests');
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> cancelfriendrequest(UserModel user) async {
    try {
      _isloading.value = true;
      final currentuserid = _authController.user?.uid;
      if (currentuserid != null) {
        final requests = _setrequests.firstWhereOrNull(
          (r) =>
              r.receiverId == user.id && r.status == FrindReqistState.pending,
        );
        if (requests != null) {
          _userrelationships[user.id] = Usererlationshipstatus.none;
          _userrelationships.refresh();

          await _firestoreServices.cancelfriendrequest(requests.id);

          Get.snackbar('success', 'friend request cancelled');
        }
      }
    } catch (e) {
      _userrelationships[user.id] = Usererlationshipstatus.friendrequestsent;
      _error.value = e.toString();
      print('error canceliing friend requests: $e');
      Get.snackbar('Error', 'failed to cancel friend requests');
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> acceptfriendrequest(UserModel user) async {
    try {
      _isloading.value = true;
      final currentuserid = _authController.user?.uid;
      if (currentuserid != null) {
        final request = _receivedrequests.firstWhereOrNull(
          (r) => r.senderId == user.id && r.status == FrindReqistState.pending,
        );
        if (request != null) {
          _userrelationships[user.id] = Usererlationshipstatus.friends;
          await _firestoreServices.respondtofriendrequest(
            request.id,
            FrindReqistState.accepted,
          );
          Get.snackbar('success', 'friend request accepted');
        }
      }
    } catch (e) {
      _userrelationships[user.id] = Usererlationshipstatus.friendrequestsent;
      _error.value = e.toString();
      print('error accepting friend requests: $e');
      Get.snackbar('Error', 'failed to accept friend requests');
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> declinefriendrequest(UserModel user) async {
    try {
      _isloading.value = true;
      final currentuserid = _authController.user?.uid;
      if (currentuserid != null) {
        final request = _receivedrequests.firstWhereOrNull(
          (r) => r.senderId == user.id && r.status == FrindReqistState.pending,
        );
        if (request != null) {
          _userrelationships[user.id] = Usererlationshipstatus.none;
          await _firestoreServices.respondtofriendrequest(
            request.id,
            FrindReqistState.declined,
          );
          Get.snackbar('success', 'friend request declined');
        }
      }
    } catch (e) {
      _userrelationships[user.id] = Usererlationshipstatus.friendrequestsent;
      _error.value = e.toString();
      print('error declining friend requests: $e');
      Get.snackbar('Error', 'failed to declined friend requests');
    } finally {
      _isloading.value = false;
    }
  }

  Future<void> startcgat(UserModel user) async {
    try {
      _isloading.value = true;
      final currentuserid = _authController.user?.uid;
      if (currentuserid != null) {
        final relationship =
            _userrelationships[user.id] ?? Usererlationshipstatus.none;
        if (relationship != Usererlationshipstatus.friends) {
          Get.snackbar(
            'info',
            'you can only chat with friends, please send a friend request firest',
          );
          return;
        }
        final chatid = await _firestoreServices.createorgetchat(
          currentuserid,
          user.id,
        );
        Get.toNamed(
          AppRoutes.chat,
          arguments: {'chatid': chatid, 'otheruser': user},
        );
      }
    } catch (e) {
      _error.value = e.toString();
      print('error starting chat : $e');
      Get.snackbar('error', 'faild to start chat');
    } finally {
      _isloading.value = false;
    }
  }

  Usererlationshipstatus getuserrelationshipstats(String userid) {
    return _userrelationships[userid] ?? Usererlationshipstatus.none;
  }

  String getrelationshipbuttontext(Usererlationshipstatus stats) {
    switch (stats) {
      case Usererlationshipstatus.none:
        return 'Add';
      case Usererlationshipstatus.friendrequestsent:
        return 'request sent';
      case Usererlationshipstatus.friendrequestreceived:
        return 'accept ';
      case Usererlationshipstatus.friends:
        return 'message';
      case Usererlationshipstatus.blocked:
        return 'blocked';
    }
  }

  IconData getrelationshipicon(Usererlationshipstatus stats) {
    switch (stats) {
      case Usererlationshipstatus.none:
        return Icons.person_add;
      case Usererlationshipstatus.friendrequestsent:
        return Icons.access_time;
      case Usererlationshipstatus.friendrequestreceived:
        return Icons.check;
      case Usererlationshipstatus.friends:
        return Icons.chat_bubble_outline;
      case Usererlationshipstatus.blocked:
        return Icons.block;
    }
  }

  Color getrelationshipcolor(Usererlationshipstatus status) {
    switch (status) {
      case Usererlationshipstatus.none:
        return Colors.blue;
      case Usererlationshipstatus.friendrequestsent:
        return Colors.orange;
      case Usererlationshipstatus.friendrequestreceived:
        return Colors.green;
      case Usererlationshipstatus.friends:
        return Colors.blue;
      case Usererlationshipstatus.blocked:
        return Colors.redAccent;
    }
  }

  void handelrelationshipaction(UserModel user) {
    final status = getuserrelationshipstats(user.id);
    switch (status) {
      case Usererlationshipstatus.none:
        sendfriendrequests(user);
        break;
      case Usererlationshipstatus.friendrequestsent:
        cancelfriendrequest(user);
        break;
      case Usererlationshipstatus.friendrequestreceived:
        acceptfriendrequest(user);
        break;
      case Usererlationshipstatus.friends:
        startcgat(user);
        break;
      case Usererlationshipstatus.blocked:
        Get.snackbar('info', 'you have blocked this user.');
        break;
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

  void _clearerror() {
    _error.value = '';
  }
}
