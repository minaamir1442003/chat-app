enum MessageType { text }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isEdited;
  final DateTime? editedat;


  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
     this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.isEdited = false,
    this.editedat
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'] ,
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      isEdited: map['isEdited'] ?? false,
      editedat: map['editedat'] !=null ? DateTime.fromMillisecondsSinceEpoch(map['editedat']):null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'isEdited': isEdited,
      'editedat': editedat?.millisecondsSinceEpoch
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isEdited,
    DateTime? editedat

  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      editedat: editedat ?? this.editedat
    );
  }
}
