import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para los mensajes del chat
class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // true = usuario, false = bot
  final DateTime timestamp;
  final String? userId; // Para guardar historial por usuario

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.userId,
  });

  /// Crea un mensaje desde Firestore
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      isUser: data['isUser'] ?? true,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'],
    );
  }

  /// Convierte a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  /// Crea una copia con modificaciones
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? userId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }
}
