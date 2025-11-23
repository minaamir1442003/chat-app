import 'package:chat/controllers/chat_conroller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:chat/views/widget/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final String chatid;
  late final ChatConroller conroller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatid = Get.arguments['chatid'] ?? "";
    if (!Get.isRegistered<ChatConroller>(tag: chatid)) {
      Get.put<ChatConroller>(ChatConroller(), tag: chatid);
    }
    conroller = Get.find<ChatConroller>(tag: chatid);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.delete<ChatConroller>(tag: chatid);
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Obx(() {
          final otheruser = conroller.otheruser;
          if (otheruser == null) return Text("Chat");
          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primecolor,
                child:
                    otheruser.photourl.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            otheruser.photourl,
                            width: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                otheruser.displayname.isNotEmpty
                                    ? otheruser.displayname[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otheruser.displayname,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      otheruser.isonline ? "Online" : "Offline",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            otheruser.isonline
                                ? AppTheme.succescolor
                                : AppTheme.textsecondrycolor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case "delete":
                  conroller.deletchat();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorcolor,
                      ),
                      title: Text("Delete Chat"),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (conroller.message.isEmpty) {
                return _buildemptystate();
              }
              return ListView.builder(
                controller: conroller.scrollcontroller,
                padding: EdgeInsets.all(16),
                itemCount: conroller.message.length,
                itemBuilder: (context, index) {
                  final message = conroller.message[index];
                  final ismymessage = conroller.ismymessage(message);
                  final showtime =
                      index == 0 ||
                      conroller.message[index - 1].timestamp
                              .difference(message.timestamp)
                              .inMinutes
                              .obs() >
                          5;
                  return MessageBubble(
                    message: message,
                    ismymessage: ismymessage,
                    showtime: showtime,
                    timetext: conroller.formatmessagetime(message.timestamp),
                    onlongpress:
                        ismymessage ? () => _showmessageoptions(message) : null,
                  );
                },
              );
            }),
          ),
          _buildmessageinput(),
        ],
      ),
    );
  }

  Widget _buildmessageinput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.bordercolor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardcolor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.bordercolor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: conroller.messagecontroller,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => conroller.sendmessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color:
                      conroller.istyping
                          ? AppTheme.primecolor
                          : AppTheme.bordercolor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  onPressed: conroller.issending ? null : conroller.sendmessage,
                  icon: Icon(Icons.send_rounded, color: conroller.istyping? Colors.white: AppTheme.textsecondrycolor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        conroller.onchatresuned();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        conroller.onchatpaused();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Widget _buildemptystate() {
    return Center(
      child: Container(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primecolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.chat_outlined,
                  size: 40,
                  color: AppTheme.primecolor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "start the conversation",
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textprimarycolor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Send a message to get started",
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textsecondrycolor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showmessageoptions(dynamic message) {
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
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.primecolor),
              title: Text("Edit Message"),
              onTap: () {
                Get.back();
                _showeditdialog(message);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppTheme.errorcolor),
              title: Text("Delet Message"),
              onTap: () {
                Get.back();
                _showdeletdialog(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showeditdialog(dynamic message) {
    final editcontroller = TextEditingController(text: message.content);
    Get.dialog(
      AlertDialog(
        title: Text("Edit Message"),
        content: TextField(
          controller: editcontroller,
          decoration: InputDecoration(hintText: 'enter new message'),
          maxLines: null,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              if (editcontroller.text.trim().isNotEmpty) {
                conroller.editmessage(message, editcontroller.text.trim());
                Get.back();
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showdeletdialog(dynamic message) {
    Get.dialog(
      AlertDialog(
        title: Text("Delet Message"),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              conroller.deletmessage(message);
              Get.back();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
}
