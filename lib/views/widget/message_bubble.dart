import 'package:chat/models/message_tybe.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool ismymessage;
  final bool showtime;
  final String timetext;
  final VoidCallback? onlongpress;
  const MessageBubble({
    super.key,
    required this.message,
    required this.ismymessage,
    required this.showtime,
    required this.timetext,
    this.onlongpress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showtime) ...[
          SizedBox(height: 16),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.textsecondrycolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timetext,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textsecondrycolor,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ] else
          SizedBox(height: 4),
        Row(
          mainAxisAlignment:
              ismymessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!ismymessage) ...[SizedBox(width: 8)],
            Flexible(
              child: GestureDetector(
                onLongPress: onlongpress,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        ismymessage ? AppTheme.primecolor : AppTheme.cardcolor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(ismymessage ? 20 : 4),
                      bottomRight: Radius.circular(ismymessage ? 20 : 4),
                    ),
                    border:
                        ismymessage
                            ? null
                            : Border.all(color: AppTheme.bordercolor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              ismymessage
                                  ? Colors.white
                                  : AppTheme.textprimarycolor,
                        ),
                      ),
                      if (message.isEdited) ...[
                        SizedBox(height: 4),
                        Text(
                          'Edited',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                ismymessage
                                    ? Colors.white.withOpacity(0.7)
                                    : AppTheme.textsecondrycolor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (ismymessage) ...[SizedBox(width: 8), _buildmessagestatus()],
          ],
        ),
      ],
    );
  }

  Widget _buildmessagestatus() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Icon(message.isRead ? Icons.done_all : Icons.done, size: 16,
      color: message.isRead?
      AppTheme.primecolor:
      AppTheme.textsecondrycolor
      ,
      ),
    );
  }
}
