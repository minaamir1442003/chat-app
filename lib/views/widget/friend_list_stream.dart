import 'package:chat/models/user_model.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';

class FriendListStream extends StatelessWidget {
  final UserModel friend;
  final String lastseentext;
  final VoidCallback ontap;
  final VoidCallback onremove;

  final VoidCallback onblock;

  FriendListStream({
    super.key,
    required this.friend,
    required this.lastseentext,
    required this.ontap,
    required this.onremove,
    required this.onblock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primecolor,
                    child:
                        friend.photourl.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                friend.photourl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                            : _builddefaultavater(),
                  ),
                ),
                if (friend.isonline)
                  Positioned(
                    bottom: 10,
                    right: 7,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.succescolor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    friend.displayname,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    friend.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textsecondrycolor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    lastseentext,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          friend.isonline
                              ? AppTheme.succescolor
                              : AppTheme.textsecondrycolor,
                      fontWeight:
                          friend.isonline ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                    case "message":
                    ontap();
                  case "remove":
                    onremove();
                    break;
                  case "block":
                    onblock();
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: "message",
                      child: ListTile(
                        leading: Icon(Icons.chat_bubble_outline,
                        color: AppTheme.primecolor,
                        ),
                        contentPadding: EdgeInsets.zero,

                        title: Text("Message"),
                      ),
                    ),
                      PopupMenuItem(
                      value: "remove",
                      child: ListTile(
                        leading: Icon(Icons.person_remove_outlined,
                        color: AppTheme.errorcolor,
                        ),
                        contentPadding: EdgeInsets.zero,

                        title: Text("Remove friend"),
                      ),
                    ),
                    PopupMenuItem(
                      value: "block",
                      child: ListTile(
                        leading: Icon(Icons.block,
                        color: AppTheme.errorcolor,
                        ),
                        contentPadding: EdgeInsets.zero,

                        title: Text("block friend"),
                      ),
                    ),
                  ],
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builddefaultavater() {
    return Text(
      friend.displayname.isNotEmpty ? friend.displayname[0].toUpperCase() : "?",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
