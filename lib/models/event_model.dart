import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String userId; // ID del organizador
  final String? img; // URL de la imagen
  final String title;
  final String description;
  final DateTime date;
  final String hour; // Formato: "18:00" o "6:00 PM"
  final String place;
  final double price; // 0 para eventos gratuitos
  final String type; // Cultura, Música, Deportes, Gastronomía, Tecnología
  final String privacity; // "public" o "private"
  final String state; // "active", "cancelled", "completed"
  final String organizer; // Nombre del organizador
  final DateTime createdAt;
  final int attendeesCount; // Contador de asistentes

  EventModel({
    required this.id,
    required this.userId,
    this.img,
    required this.title,
    required this.description,
    required this.date,
    required this.hour,
    required this.place,
    this.price = 0.0,
    required this.type,
    this.privacity = 'public',
    this.state = 'active',
    required this.organizer,
    required this.createdAt,
    this.attendeesCount = 0,
  });

  // Convertir desde Firestore
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      img: data['img'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      hour: data['hour'] ?? '',
      place: data['place'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      type: data['type'] ?? 'Cultura',
      privacity: data['privacity'] ?? 'public',
      state: data['state'] ?? 'active',
      organizer: data['organizer'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      attendeesCount: data['attendeesCount'] ?? 0,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'img': img,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'hour': hour,
      'place': place,
      'price': price,
      'type': type,
      'privacity': privacity,
      'state': state,
      'organizer': organizer,
      'createdAt': Timestamp.fromDate(createdAt),
      'attendeesCount': attendeesCount,
    };
  }

  // Copiar con modificaciones
  EventModel copyWith({
    String? id,
    String? userId,
    String? img,
    String? title,
    String? description,
    DateTime? date,
    String? hour,
    String? place,
    double? price,
    String? type,
    String? privacity,
    String? state,
    String? organizer,
    DateTime? createdAt,
    int? attendeesCount,
  }) {
    return EventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      img: img ?? this.img,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      place: place ?? this.place,
      price: price ?? this.price,
      type: type ?? this.type,
      privacity: privacity ?? this.privacity,
      state: state ?? this.state,
      organizer: organizer ?? this.organizer,
      createdAt: createdAt ?? this.createdAt,
      attendeesCount: attendeesCount ?? this.attendeesCount,
    );
  }

  // Verificar si el evento es gratuito
  bool get isFree => price == 0.0;

  // Obtener precio formateado
  String get formattedPrice {
    if (isFree) return 'Gratis';
    return '\$${price.toStringAsFixed(0)}';
  }

  // Verificar si el evento está activo
  bool get isActive => state == 'active';

  // Verificar si el evento ya pasó
  bool get isPast => date.isBefore(DateTime.now());
}
