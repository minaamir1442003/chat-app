import 'package:chat/models/frind_reqist_state.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';

class FriendRequestItem extends StatelessWidget {
  final FrindReqistModel request;
  final UserModel user;
  final String timetext;
  final bool isreceived;
  final VoidCallback? onaccept;
  final VoidCallback? ondecline;
  final String? statustext;
  final Color? statuscolor;

  const FriendRequestItem({
    super.key,
    required this.request,
    required this.user,
    required this.timetext,
    required this.isreceived,
    this.onaccept,
    this.ondecline,
    this.statustext,
    this.statuscolor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primecolor,
                  child:
                      user.photourl.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              user.photourl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  user.displayname.isNotEmpty
                                      ? user.displayname[0].toUpperCase()
                                      : '?',
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
                            user.displayname.isNotEmpty
                                ? user.displayname[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayname,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timetext,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textsecondrycolor),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isreceived && request.status == FrindReqistState.pending) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onaccept,
                      icon: Icon(Icons.check),
                      label: Text("Accept"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.succescolor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: ondecline,
                      icon: Icon(Icons.close),
                      label: Text("decline"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.errorcolor),
                        foregroundColor: AppTheme.errorcolor,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (!isreceived && statustext != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: statuscolor?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statuscolor ?? AppTheme.bordercolor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getstatusicon(), size: 16, color: statuscolor),
                    SizedBox(width: 6),
                    Text(
                      statustext!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statuscolor??AppTheme.textsecondrycolor,
                        fontWeight: FontWeight.w600,

                      ),
                    )
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getstatusicon() {
    switch (request.status) {
      case FrindReqistState.accepted:
        return Icons.check_circle;
      case FrindReqistState.declined:
        return Icons.cancel;
      case FrindReqistState.pending:
      default:
        return Icons.hourglass_top;
    }
  }
}
