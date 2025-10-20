enum FrindReqistState { pending, accepted, declined }

class FrindReqistModel {
  final String id;
  final String senderId;
  final String receiverId;
  final FrindReqistState status;
  final DateTime createdAt;
  final DateTime? responseAt;
  final String? message;

  FrindReqistModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
     this.status = FrindReqistState.pending,
    required this.createdAt,
    this.responseAt,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name, // enum -> String
      'createdAt': createdAt.millisecondsSinceEpoch,
      'responseAt': responseAt?.millisecondsSinceEpoch,
      'message': message,
    };
  }

  factory FrindReqistModel.fromMap(Map<String, dynamic> map) {
    return FrindReqistModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: FrindReqistState.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FrindReqistState.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']??0),
      responseAt: map['responseAt'] != null?
      DateTime.fromMillisecondsSinceEpoch(map['responseAt']):
      null,
      message: map['message'],
    );
  }

  FrindReqistModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    FrindReqistState? status,
    DateTime? createdAt,
    DateTime? responseAt,
    String? message,
  }) {
    return FrindReqistModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      responseAt: responseAt ?? this.responseAt,
      message: message ?? this.message,
    );
  }
}
