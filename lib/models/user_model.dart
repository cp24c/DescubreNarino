import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role; // "user" o "organizer"
  final String state;
  final String? userImg;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    this.state = 'active',
    this.userImg,
    required this.createdAt,
  });

  // Convertir desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      state: data['state'] ?? 'active',
      userImg: data['user_img'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'state': state,
      'user_img': userImg,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copiar con modificaciones
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? role,
    String? state,
    String? userImg,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      state: state ?? this.state,
      userImg: userImg ?? this.userImg,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
