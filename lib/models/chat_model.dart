class ChatModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> deletedBy;
  final Map<String, DateTime?> deletedAt;
  final Map<String, DateTime?> lastSeenBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    this.deletedBy = const {},
    this.deletedAt = const {},
    this.lastSeenBy = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  static ChatModel fromMap(Map<String, dynamic> map) {
    Map<String, DateTime?> lastseenmap = {};
    if (map['lastSeenBy'] != null) {
      Map<String, dynamic> rawlastseen = Map<String, dynamic>.from(
        map['lastSeenBy'],
      );
      lastseenmap = rawlastseen.map(
        (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null,
        ),
      );
    }
    Map<String, DateTime?> deletedatmap = {};
    if (map['deletedAt'] != null) {
      Map<String, dynamic> rawdeletedat = Map<String, dynamic>.from(
        map['deletedAt'],
      );
      deletedatmap = rawdeletedat.map(
        (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null,
        ),
      );
    }
    return ChatModel(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime:
          map['lastMessageTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
              : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      deletedBy: Map<String, bool>.from(map['deletedBy'] ?? {}),
      deletedAt: deletedatmap,
      lastSeenBy: lastseenmap,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt.map(
        (key, value) => MapEntry(key, value?.millisecondsSinceEpoch),
      ),
      'lastSeenBy': lastSeenBy.map(
        (key, value) => MapEntry(key, value?.millisecondsSinceEpoch),
      ),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? deletedBy,
    Map<String, DateTime?>? deletedAt,
    Map<String, DateTime?>? lastSeenBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      deletedBy: deletedBy ?? this.deletedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSeenBy: lastSeenBy ?? this.lastSeenBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getotherparticipant(String currentuserid) {
    return participants.firstWhere(
      (id) => id != currentuserid,
      orElse: () => '',
    );
  }

  int getunreadcount(String userid) {
    return unreadCount[userid] ?? 0;
  }

  bool isdeletedby(String userid) {
    return deletedBy[userid] ?? false;
  }

  DateTime? getdeletedat(String userid) {
    return deletedAt[userid];
  }

  DateTime? getlastseenby(String userid) {
    return lastSeenBy[userid];
  }

  bool ismessageseen(String currentuserid, String otherid) {
    if (lastMessageSenderId == currentuserid) {
      final otheruserlastseen = getlastseenby(otherid);
      if (otheruserlastseen != null && lastMessageTime != null) {
        return otheruserlastseen.isAfter(lastMessageTime!) ||
            otheruserlastseen.isAtSameMomentAs(lastMessageTime!);
      }
    }
    return false;
  }
}
