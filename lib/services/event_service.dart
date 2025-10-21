import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear un nuevo evento
  Future<String> createEvent(EventModel event) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('events').add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Error al crear evento: $e';
    }
  }

  // Obtener todos los eventos activos
  Stream<List<EventModel>> getActiveEvents() {
    return _firestore
        .collection('events')
        .where('state', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final events =
          snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  // Obtener eventos por categoría
  Stream<List<EventModel>> getEventsByCategory(String category) {
    if (category == 'Todos') {
      return getActiveEvents();
    }

    return _firestore
        .collection('events')
        .where('state', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((event) => event.type == category)
          .toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  // Obtener eventos creados por un usuario específico
  Stream<List<EventModel>> getUserEvents(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final events =
          snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return events;
    });
  }

  // Obtener un evento específico
  Future<EventModel?> getEventById(String eventId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('events').doc(eventId).get();

      if (!doc.exists) return null;
      return EventModel.fromFirestore(doc);
    } catch (e) {
      throw 'Error al obtener evento: $e';
    }
  }

  // Actualizar un evento
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('events').doc(eventId).update(data);
    } catch (e) {
      throw 'Error al actualizar evento: $e';
    }
  }

  // Eliminar un evento
  // NOTA: Las imágenes de Cloudinary se quedan ahí (no hay API de eliminación en cloudinary_public)
  // Si necesitas eliminarlas, debes usar la API Admin de Cloudinary desde el backend
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw 'Error al eliminar evento: $e';
    }
  }

  // Buscar eventos por título
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('state', isEqualTo: 'active')
          .get();

      List<EventModel> allEvents =
          snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();

      return allEvents.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw 'Error al buscar eventos: $e';
    }
  }

  // Agregar evento a favoritos
  Future<void> addToFavorites(String userId, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(eventId)
          .set({
        'eventId': eventId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error al agregar a favoritos: $e';
    }
  }

  // Eliminar evento de favoritos
  Future<void> removeFromFavorites(String userId, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(eventId)
          .delete();
    } catch (e) {
      throw 'Error al eliminar de favoritos: $e';
    }
  }

  // Verificar si un evento está en favoritos
  Stream<bool> isEventFavorite(String userId, String eventId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(eventId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Obtener eventos favoritos del usuario
  Stream<List<EventModel>> getFavoriteEvents(String userId) async* {
    try {
      var favoritesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      if (favoritesSnapshot.docs.isEmpty) {
        yield [];
        return;
      }

      List<String> eventIds = favoritesSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      List<EventModel> favoriteEvents = [];
      for (String eventId in eventIds) {
        var eventDoc = await _firestore.collection('events').doc(eventId).get();

        if (eventDoc.exists) {
          favoriteEvents.add(EventModel.fromFirestore(eventDoc));
        }
      }

      yield favoriteEvents;
    } catch (e) {
      yield [];
    }
  }

  // Incrementar contador de asistentes
  Future<void> markAttendance(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'attendeesCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Error al marcar asistencia: $e';
    }
  }

  // Obtener eventos destacados
  Stream<List<EventModel>> getFeaturedEvents() {
    return _firestore
        .collection('events')
        .where('state', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((event) => event.date.isAfter(DateTime.now()))
          .toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events.take(5).toList();
    });
  }
}
