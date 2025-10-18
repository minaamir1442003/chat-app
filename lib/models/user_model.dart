import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayname;
  final String photourl;
  final bool isonline;
  final DateTime lastseen;
  final DateTime createdat;

  UserModel({
    required this.id,
    required this.email,
    required this.displayname,
    this.photourl = "",
    this.isonline = false,
    required this.lastseen,
    required this.createdat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayname': displayname,
      'photourl': photourl,
      'isonline': isonline,
      'lastseen': lastseen.toIso8601String(),
      'createdat': createdat.toIso8601String(),
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayname: map['displayname'] ?? '',
      photourl: map['photourl'] ?? '',
      isonline: map['isonline'] ?? false,
      lastseen: parseDate(map['lastseen']),
      createdat: parseDate(map['createdat']),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayname,
    String? photourl,
    bool? isonline,
    DateTime? lastseen,
    DateTime? createdat,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayname: displayname ?? this.displayname,
      photourl: photourl ?? this.photourl,
      isonline: isonline ?? this.isonline,
      lastseen: lastseen ?? this.lastseen,
      createdat: createdat ?? this.createdat,
    );
  }
}
