import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/models/message_tybe.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatConroller extends GetxController {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController messagecontroller = TextEditingController();
  final Uuid _uuid = Uuid();
  ScrollController? _scrollController;
  ScrollController get scrollcontroller {
    _scrollController ??= ScrollController();
    return _scrollController!;
  }

  final RxList<MessageModel> _messages = <MessageModel>[].obs;
  final RxBool _isloading = false.obs;
  final RxBool _issending = false.obs;
  final RxString _error = ''.obs;
  final Rx<UserModel?> _otheruser = Rx<UserModel?>(null);
  final RxString _chatid = ''.obs;
  final RxBool _istyping = false.obs;
  final RxBool _ischatactive = false.obs;
  List<MessageModel> get message => _messages;
  bool get isloading => _isloading.value;
  bool get issending => _issending.value;
  String get error => _error.value;
  UserModel? get otheruser => _otheruser.value;
  String get chatid => _chatid.value;
  bool get istyping => _istyping.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _initializedchat();

    messagecontroller.addListener(_onmessagechaged);
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    _ischatactive.value = true;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    _ischatactive.value = false;
    _markmessageasread();
    super.onClose();
  }

  void _initializedchat() {
    final arguments = Get.arguments;
    if (arguments != null) {
      _chatid.value = arguments['chatid'] ?? "";
      _otheruser.value = arguments["otheruser"];
      _loadmessages();
      _markmessageasread();
    }
  }

  void _loadmessages() {
    final currentuserid = _authController.user?.uid;
    final otheruserid = _otheruser.value?.id;
    if (currentuserid != null && otheruserid != null) {
      _messages.bindStream(
        _firestoreServices.getmessagestram(currentuserid, otheruserid),
      );
      ever(_messages, (List<MessageModel> messageslist) {
        if (_ischatactive.value) {
          _markunreadmessagesasread(messageslist);
        }
        _scrolltobottom();
      });
    }
  }

  void _scrolltobottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController != null && _scrollController!.hasClients) {
        _scrollController!.animateTo(
          _scrollController!.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _markunreadmessagesasread(List<MessageModel> messagelist) async {
    final currentuserid = _authController.user?.uid;
    if (currentuserid == null) return;
    try {
      final unreadmessages =
          messagelist
              .where(
                (message) =>
                    message.receiverId == currentuserid &&
                    !message.isRead &&
                    message.senderId != currentuserid,
              )
              .toList();
      for (var message in unreadmessages) {
        await _firestoreServices.markmessageasread(message.id);
      }
      if (unreadmessages.isNotEmpty && _chatid.value.isNotEmpty) {
        await _firestoreServices.restorunreadcount(
          _chatid.value,
          currentuserid,
        );
      }
      if (_chatid.value.isNotEmpty) {
        await _firestoreServices.updateuserlastseen(
          _chatid.value,
          currentuserid,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletchat() async {
    try {
      final currentuserid = _authController.user?.uid;
      if (currentuserid == null || _chatid.value.isEmpty) return;
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("delete chat"),
          content: Text(
            "Are you sure you want to delete this chat? this action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text("Delete"),
            ),
          ],
        ),
      );
      if (result == true) {
        _isloading.value = true;
        await _firestoreServices.deletechatforuser(
          _chatid.value,
          currentuserid,
        );
        Get.delete<ChatConroller>(tag: _chatid.string);
        Get.back();
        Get.snackbar('Success', "Chat Deleted");
      }
    } catch (e) {
      _error.value = e.toString();
      print(e);
      Get.snackbar('Error', "Failed to Chat Deleted");
    } finally {
      _isloading.value = false;
    }
  }

  void _onmessagechaged() {
    _istyping.value = messagecontroller.text.isNotEmpty;
  }

  Future<void> sendmessage() async {
    final currentuserid = _authController.user?.uid;
    final otheruserid = _otheruser.value?.id;
    final content = messagecontroller.text.trim();
    messagecontroller.clear();
    if (currentuserid == null || otheruserid == null || content.isEmpty) {
      Get.snackbar("Error", "You cannot send message to this user");
      
      return;
    }
    if (await _firestoreServices.unfriendcheck(currentuserid, otheruserid)) {
      Get.snackbar("Error", "You cannot send message to this user");
      return;
    }
    try {
      _issending.value = true;
      final message = MessageModel(
        id: _uuid.v4(),
        senderId: currentuserid,
        receiverId: otheruserid,
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );
      await _firestoreServices.sendmessage(message);
      _istyping.value = false;
      _scrolltobottom();
    } catch (e) {
    
    } finally {
      _issending.value = false;
    }
  }

  Future<void> _markmessageasread() async {
    final currentuserid = _authController.user?.uid;
    if (currentuserid != null && _chatid.value.isNotEmpty) {
      try {
        await _firestoreServices.restorunreadcount(
          _chatid.value,
          currentuserid,
        );
      } catch (e) {
        print(e);
      }
    }
  }

  void onchatresuned() {
    _ischatactive.value = true;
    _markunreadmessagesasread(_messages);
  }

  void onchatpaused() {
    _ischatactive.value = false;
  }

  Future<void> deletmessage(MessageModel message) async {
    try {
      await _firestoreServices.deletemessage(message.id);
      Get.snackbar("Success", "Message deleted");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete message");
      print(e);
    }
  }

  Future<void> editmessage(MessageModel message, String newconteny) async {
    try {
      await _firestoreServices.editmessgae(message.id, newconteny);
      Get.snackbar("Success", "Message edited");
    } catch (e) {
      Get.snackbar("Error", "Failed to edit message");
      print(e);
    }
  }

  bool ismymessage(MessageModel message) {
    return message.senderId == _authController.user?.uid;
  }

  String formatmessagetime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')} : ${timestamp.minute.toString().padLeft(2, '0')} hours ago';
    } else if (difference.inDays < 7) {
      final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return "${day[timestamp.weekday - 1]} ${timestamp.hour.toString().padLeft(2, '0')} : ${timestamp.minute.toString().padLeft(2, '0')} ";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }

  void clearerror() {
    _error.value = '';
  }
}
