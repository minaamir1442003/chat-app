import 'package:chat/models/chat_model.dart';
import 'package:chat/models/frind_reqist_state.dart';
import 'package:chat/models/frind_ship_model.dart';
import 'package:chat/models/message_tybe.dart';
import 'package:chat/models/notification_moodel.dart';
import 'package:chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> creatuser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception("failed to creat user: ${e.toString()}");
    }
  }

  Future<UserModel?> getuser(String userid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('faild to get user ${e.toString()}');
    }
  }

  Future<void> updateuseronlinestate(String userid, bool isonline) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userid).get();
      if (doc.exists) {
        await _firestore.collection('users').doc(userid).update({
          'isonline': isonline,
          'lastseen': DateTime.now(),
        });
      }
    } catch (e) {
      throw Exception('faild to get user online state ${e.toString()}');
    }
  }

  Future<void> deletuser(String userid) async {
    try {
      await _firestore.collection('users').doc(userid).delete();
    } catch (e) {
      throw Exception('faild to delet user ${e.toString()}');
    }
  }

  Stream<UserModel?> getuserstream(String userid) {
    return _firestore
        .collection('users')
        .doc(userid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<void> updateuser(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception("Failed to updateuser");
    }
  }

  Stream<List<UserModel>> getallusersstream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshort) =>
              snapshort.docs
                  .map((doc) => UserModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Future<void> sendfrindrequest(FrindReqistModel request) async {
    try {
      await _firestore
          .collection('friendships')
          .doc(request.id)
          .set(request.toMap());
      String notificationid =
          'frend request ${request.senderId}_${request.receiverId}_${DateTime.now().millisecondsSinceEpoch}';
      await creatnotification(
        NotificationModel(
          id: notificationid,
          userId: request.receiverId,
          title: 'new friend request',
          body: 'you have received a new friend request',
          type: NotificationType.friendRequest,

          data: {'senderId': request.senderId, 'receiverId': request.id},
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('failed to send friend reqest : ${e.toString()}');
    }
  }

  Future<void> cancelfriendrequest(String requestid) async {
    try {
      DocumentSnapshot requestdoc =
          await _firestore.collection('friendships').doc(requestid).get();
      if (requestdoc.exists) {
        FrindReqistModel request = FrindReqistModel.fromMap(
          requestdoc.data() as Map<String, dynamic>,
        );
        await _firestore.collection('friendships').doc(requestid).delete();
        await deletenotificationsbytypeanduser(
          request.receiverId,
          NotificationType.friendRequest,
          request.senderId,
        );
      }
    } catch (e) {
      throw Exception('failed to cancel friend request : ${e.toString()}');
    }
  }

  Future<void> respondtofriendrequest(
    String requestid,
    FrindReqistState status,
  ) async {
    try {
      // تحديث حالة طلب الصداقة
      await _firestore.collection('friendships').doc(requestid).update({
        'status': status.name,
        'respondedat': DateTime.now().millisecondsSinceEpoch,
      });

      DocumentSnapshot requestdoc =
          await _firestore.collection('friendships').doc(requestid).get();

      if (requestdoc.exists) {
        FrindReqistModel request = FrindReqistModel.fromMap(
          requestdoc.data() as Map<String, dynamic>,
        );

        if (status == FrindReqistState.accepted) {
          print(
            '✅ Creating REAL friendship between ${request.senderId} and ${request.receiverId}',
          );

          // ✅ إنشاء صداقة حقيقية (ليست مجرد طلب مقبول)
          await creatfriendship(request.senderId, request.receiverId);

          await creatnotification(
            NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: 'Friend Request Accepted',
              body: 'Your friend request has been accepted',
              type: NotificationType.friendRequestAccepted,
              createdAt: DateTime.now(),
              data: {'userid': request.receiverId},
            ),
          );

          await _removenotificationforcancelledrequest(
            request.receiverId,
            request.senderId,
          );

          print('🎉 Real friendship created successfully!');
        } else if (status == FrindReqistState.declined) {
          await creatnotification(
            NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: 'Friend Request Declined',
              body: 'Your friend request has been declined',
              type: NotificationType.friendRequestDeclined, // ✅ تصحيح النوع
              createdAt: DateTime.now(),
              data: {'userid': request.receiverId},
            ),
          );

          await _removenotificationforcancelledrequest(
            request.receiverId,
            request.senderId,
          );
        }
      }
    } catch (e) {
      print('❌ Error in respondtofriendrequest: $e');
      throw Exception('Failed to respond to friend request: ${e.toString()}');
    }
  }

  Stream<List<FrindReqistModel>> getfriendrequeststream(String userid) {
    return _firestore
        .collection('friendships')
        .where('receiverId', isEqualTo: userid)
        .where('status', isEqualTo: 'pending')
        .snapshots() // إزالة orderBy لتجنب index
        .map((snapshot) {
          var requests =
              snapshot.docs
                  .map((doc) => FrindReqistModel.fromMap(doc.data()))
                  .toList();
          // ترتيب محلي بدلاً من orderBy في query
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Stream<List<FrindReqistModel>> getsentfriendrequestsstream(String userid) {
    return _firestore
        .collection('friendships')
        .where('senderId', isEqualTo: userid)
        .snapshots() // إزالة orderBy
        .map((snapshot) {
          var requests =
              snapshot.docs
                  .map((doc) => FrindReqistModel.fromMap(doc.data()))
                  .toList();
          // ترتيب محلي
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Future<FrindReqistModel?> getfriendrequest(
    String senderid,
    String receiverid,
  ) async {
    try {
      QuerySnapshot query =
          await _firestore
              .collection('friendships')
              .where('senderId', isEqualTo: senderid)
              .where('receiverId', isEqualTo: receiverid)
              .get();
      if (query.docs.isNotEmpty) {
        return FrindReqistModel.fromMap(
          query.docs.first.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('failed to get friend request: ${e.toString()}');
    }
  }

  //friendships collection
  Future<void> creatfriendship(String user1id, String user2id) async {
    try {
      List<String> userids = [user1id, user2id];
      userids.sort();
      String friendshipid = '${userids[0]} _ ${userids[1]}';
      FriendshipModel friendship = FriendshipModel(
        id: friendshipid,
        user1Id: userids[0],
        user2Id: userids[1],
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('friendships')
          .doc(friendshipid)
          .set(friendship.toMap());
    } catch (e) {
      throw Exception('failed to creat friendship: ${e.toString()}');
    }
  }

  Future<void> removefriendship(String user1id, String user2id) async {
    try {
      List<String> userids = [user1id, user2id];
      userids.sort();
      String friendshipid = '${userids[0]} _ ${userids[1]}';
      await _firestore.collection('friendships').doc(friendshipid).delete();
      await creatnotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user2id,
          title: 'friend remove',
          body: 'you are no longer friends',
          type: NotificationType.friendRemoved,

          data: {'userid': user1id},
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('failed to remove friendship: ${e.toString()}');
    }
  }

  Future<void> blockeduser(String blockerid, String blockedid) async {
    try {
      List<String> userids = [blockerid, blockedid];
      userids.sort();
      String friendshipid = '${userids[0]} _ ${userids[1]}';
      await _firestore.collection('friendships').doc(friendshipid).update({
        'isBlocked': true,
        'blockedBy': blockerid,
      });
    } catch (e) {
      throw Exception('failed to block user: ${e.toString()}');
    }
  }

  Future<void> unblockeduser(String user1id, String user2id) async {
    try {
      List<String> userids = [user1id, user2id];
      userids.sort();
      String friendshipid = '${userids[0]} _ ${userids[1]}';
      await _firestore.collection('friendships').doc(friendshipid).update({
        'isBlocked': false,
        'blockedBy': null,
      });
    } catch (e) {
      throw Exception('failed to unblock user: ${e.toString()}');
    }
  }

  Stream<List<FriendshipModel>> getfriendsstream(String userid) {
    return _firestore
        .collection('friendships')
        .where('user1Id', isEqualTo: userid)
        .snapshots()
        .asyncMap((snapshot1) async {
          QuerySnapshot snapshot2 =
              await _firestore
                  .collection('friendships')
                  .where('user2Id', isEqualTo: userid)
                  .get();

          List<FriendshipModel> friendships = [];

          // معالجة النتائج من الاستعلام الأول
          for (var doc in snapshot1.docs) {
            try {
              var data = doc.data() as Map<String, dynamic>;
              // ✅ تخطي طلبات الصداقة
              if (data.containsKey('senderId') ||
                  data.containsKey('receiverId')) {
                print('⏩ Skipping friend request: ${doc.id}');
                continue;
              }

              var friendship = FriendshipModel.fromMap(data);

              // ✅ تصفية الصداقات مع النفس
              if (friendship.user1Id == friendship.user2Id) {
                print('🚫 Skipping self-friendship: ${friendship.id}');
                continue;
              }

              print('👥 Real friendship from user1Id: ${friendship.id}');
              friendships.add(friendship);
            } catch (e) {
              print('❌ Error parsing friendship doc: $e');
            }
          }

          // معالجة النتائج من الاستعلام الثاني
          for (var doc in snapshot2.docs) {
            try {
              var data = doc.data() as Map<String, dynamic>;
              // ✅ تخطي طلبات الصداقة
              if (data.containsKey('senderId') ||
                  data.containsKey('receiverId')) {
                print('⏩ Skipping friend request: ${doc.id}');
                continue;
              }

              var friendship = FriendshipModel.fromMap(data);

              // ✅ تصفية الصداقات مع النفس
              if (friendship.user1Id == friendship.user2Id) {
                print('🚫 Skipping self-friendship: ${friendship.id}');
                continue;
              }

              print('👥 Real friendship from user2Id: ${friendship.id}');
              friendships.add(friendship);
            } catch (e) {
              print('❌ Error parsing friendship doc: $e');
            }
          }

          // ✅ إزالة التكرارات (لأن نفس الصداقة قد تظهر في كلا الاستعلامين)
          friendships = friendships.toSet().toList();

          print('📊 Total real friendships found: ${friendships.length}');
          final filtered = friendships.where((f) => !f.isBlocked).toList();
          print('✅ Non-blocked real friendships: ${filtered.length}');

          return filtered;
        });
  }

  Future<FriendshipModel?> getfriendships(
    String user1id,
    String user2id,
  ) async {
    try {
      List<String> userids = [user1id, user2id];
      userids.sort();
      String friendshipid = '${userids[0]} _ ${userids[1]}';
      DocumentSnapshot doc =
          await _firestore.collection('friendships').doc(friendshipid).get();
      if (doc.exists) {
        return FriendshipModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('failed to get friendship: ${e.toString()}');
    }
  }

  Future<bool> isuserblocked(String userid, String otheruserid) async {
    try {
      List<String> userids = [userid, otheruserid];
      userids.sort();
      String friendshipid = '${userids[0]} _ ${userids[1]}';
      DocumentSnapshot doc =
          await _firestore.collection('friendships').doc(friendshipid).get();
      if (doc.exists) {
        FriendshipModel friendshipModel = FriendshipModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );
        return friendshipModel.isBlocked;
      }
      return false;
    } catch (e) {
      throw Exception('failed to check if user is blocked: ${e.toString()}');
    }
  }

  //chat collection
  Future<String> createorgetchat(String user1id, String user2id) async {
    try {
      List<String> participants = [user1id, user2id];
      participants.sort();
      String chatid = '${participants[0]} _ ${participants[1]}';
      DocumentReference chatref = _firestore.collection('chats').doc(chatid);
      DocumentSnapshot chatdoc = await chatref.get();
      if (!chatdoc.exists) {
        ChatModel newchat = ChatModel(
          id: chatid,
          participants: participants,
          unreadCount: {user1id: 0, user2id: 0},
          deletedBy: {user1id: false, user2id: false},
          deletedAt: {user1id: null, user2id: null},
          lastSeenBy: {user1id: DateTime.now(), user2id: DateTime.now()},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await chatref.set(newchat.toMap());
      } else {
        ChatModel existingchat = ChatModel.fromMap(
          chatdoc.data() as Map<String, dynamic>,
        );
        if (existingchat.isdeletedby(user1id)) {
          await restorechatforuser(chatid, user1id);
        }
        if (existingchat.isdeletedby(user2id)) {
          await restorechatforuser(chatid, user2id);
        }
      }
      return chatid;
    } catch (e) {
      throw Exception('failed to creat or get chat: ${e.toString()}');
    }
  }

  Stream<List<ChatModel>> getuserchatsstream(String userid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userid)
        .snapshots() // إزالة orderBy
        .map((snapshot) {
          var chats =
              snapshot.docs
                  .map((doc) => ChatModel.fromMap(doc.data()))
                  .where((chat) => !chat.isdeletedby(userid))
                  .toList();
          // ترتيب محلي
          chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return chats;
        });
  }

  Future<void> updatechatlastmessage(
    String chatid,
    MessageModel message,
  ) async {
    try {
      await _firestore.collection('chats').doc(chatid).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
        'lastMessageSenderId': message.senderId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to update chat last message: ${e.toString()}');
    }
  }

  Future<void> updateuserlastseen(String chatid, String userid) async {
    try {
      await _firestore.collection('chats').doc(chatid).update({
        'lastSeenBy.$userid': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to update last seen: ${e.toString()}');
    }
  }

  Future<void> deletechatforuser(String chatid, String userid) async {
    try {
      await _firestore.collection('chats').doc(chatid).update({
        'deletedBy.$userid': true,
        'deletedAt.$userid': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to delet chat: ${e.toString()}');
    }
  }

  Future<void> restorechatforuser(String chatid, String userid) async {
    try {
      await _firestore.collection('chats').doc(chatid).update({
        'deletedBy.$userid': false,
      });
    } catch (e) {
      throw Exception('failed to restore chat: ${e.toString()}');
    }
  }

  Future<void> updateunreadcount(
    String chatid,
    String userid,
    int count,
  ) async {
    try {
      await _firestore.collection('chats').doc(chatid).update({
        'unreadCount.$userid': count,
      });
    } catch (e) {
      throw Exception('failed to update unread count: ${e.toString()}');
    }
  }

  Future<void> restorunreadcount(String chatid, String userid) async {
    try {
      await _firestore.collection('chats').doc(chatid).update({
        'unreadCount.$userid': 0,
      });
    } catch (e) {
      throw Exception('failed to rest unread count: ${e.toString()}');
    }
  }

  //message collection
  Future<void> sendmessage(MessageModel message) async {
    try {
      await _firestore
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());
      String chatid = await createorgetchat(
        message.senderId,
        message.receiverId,
      );
      await updatechatlastmessage(chatid, message);
      await updateuserlastseen(chatid, message.senderId);
      DocumentSnapshot chatdoc =
          await _firestore.collection('chats').doc(chatid).get();
      if (chatdoc.exists) {
        ChatModel chat = ChatModel.fromMap(
          chatdoc.data() as Map<String, dynamic>,
        );
        int currentunread = chat.getunreadcount(message.receiverId);
        await updateunreadcount(chatid, message.receiverId, currentunread + 1);
      }
    } catch (e) {
      throw Exception('failed to send message: ${e.toString()}');
    }
  }

  Stream<List<MessageModel>> getmessagestram(String userid1, String userid2) {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [userid1, userid2])
        .snapshots()
        .asyncMap((snapshots) async {
          List<String> participants = [userid1, userid2];
          participants.sort();
          String chatid = '${participants[0]}_${participants[1]}';
          DocumentSnapshot chatdoc =
              await _firestore.collection('chats').doc(chatid).get();
          ChatModel? chat;
          if (chatdoc.exists) {
            chat = ChatModel.fromMap(chatdoc.data() as Map<String, dynamic>);
          }
          List<MessageModel> messages = [];
          for (var doc in snapshots.docs) {
            MessageModel message = MessageModel.fromMap(doc.data());
            if (((message.senderId == userid1) &&
                    message.receiverId == userid2) ||
                (message.senderId == userid2 &&
                    message.receiverId == userid1)) {
              bool includemessages = true;
              if (chat != null) {
                DateTime? currentuserdeletedat = chat.getdeletedat(userid1);
                if (currentuserdeletedat != null &&
                    message.timestamp.isBefore(currentuserdeletedat)) {
                  includemessages = false;
                }
              }
              if (includemessages) {
                messages.add(message);
              }
            }
          }
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  Future<void> markmessageasread(String messageid) async {
    try {
      await _firestore.collection('messages').doc(messageid).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('failed to mark messsage as read: ${e.toString()}');
    }
  }

  Future<void> deletemessage(String messageid) async {
    try {
      await _firestore.collection('messages').doc(messageid).delete();
    } catch (e) {
      throw Exception('failed to delet message: ${e.toString()}');
    }
  }

  Future<void> editmessgae(String messageid, String newcontent) async {
    try {
      await _firestore.collection('messages').doc(messageid).update({
        'content': newcontent,
        'isEdited': true,
        'editedat': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to edit message: ${e.toString()}');
    }
  }

  //notification collection
  Future<void> creatnotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('failed to creat notification: ${e.toString()}');
    }
  }

  Stream<List<NotificationModel>> getnotificationsstram(String userid) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshots) =>
              snapshots.docs
                  .map((doc) => NotificationModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Future<void> marknotificationasread(String notificationid) async {
    try {
      await _firestore.collection('notifications').doc(notificationid).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> markallnotificationsasread(String userid) async {
    try {
      QuerySnapshot notifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userid)
              .where('isRead', isEqualTo: false)
              .get();
      WriteBatch batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception(
        'failed to mark all notification as read: ${e.toString()}',
      );
    }
  }

  Future<void> deletnotification(String notificationid) async {
    try {
      await _firestore.collection('notifications').doc(notificationid).delete();
    } catch (e) {
      throw Exception('failed to delet notification: ${e.toString()}');
    }
  }

  Future<void> deletenotificationsbytypeanduser(
    String userid,
    NotificationType type,
    String relateduserid,
  ) async {
    try {
      QuerySnapshot notifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userid)
              .where('type', isEqualTo: type.name)
              .get();
      WriteBatch batch = _firestore.batch();
      for (var doc in notifications.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['data'] != null &&
            (data['data']['senderId'] == relateduserid ||
                data['data']['userId'] == relateduserid)) {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();
    } catch (e) {
      // throw Exception('failed to delet notification: ${e.toString()}');
      print('error deleting notification: ${e.toString()}');
    }
  }

  Future<void> _removenotificationforcancelledrequest(
    String receiverid,
    String senderid,
  ) async {
    try {
      await deletenotificationsbytypeanduser(
        receiverid,
        NotificationType.friendRequest,
        senderid,
      );
    } catch (e) {
      print(
        'error removing notification for cancelled request: ${e.toString()}',
      );
    }
  }
}
