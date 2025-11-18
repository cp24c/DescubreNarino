import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:descubre_narino/models/chat_message_model.dart';
import 'package:descubre_narino/models/event_model.dart';
import 'package:descubre_narino/services/event_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventService _eventService = EventService();

  static const String _apiKey = 'AIzaSyC4dbU4hos6mqVYRfmKNJh1WMeYohWpXE4';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatbotService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      systemInstruction: Content.system(_getSystemPrompt()),
      generationConfig: GenerationConfig(
        temperature: 0.7, // Creatividad moderada
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024, // Respuestas concisas
      ),
      safetySettings: [
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.dangerousContent,
          HarmBlockThreshold.medium,
        ),
      ],
    );

    _chat = _model.startChat();
  }

  String _getSystemPrompt() {
    return '''
Eres "NariñoBot", un asistente virtual amigable y experto en eventos culturales, 
gastronómicos, deportivos y turísticos del departamento de Nariño, Colombia.

PERSONALIDAD:
- Eres cálido, servicial y orgulloso de Nariño
- Usas un tono conversacional y cercano
- Ocasionalmente usas expresiones típicas colombianas de forma natural
- Te apasiona promover la cultura y eventos de Nariño

TUS CAPACIDADES:
1. Informar sobre eventos actuales en Nariño (música, cultura, deportes, gastronomía, etc). Tienes acceso a todos los eventos
2. Recomendar lugares, actividades y eventos
3. Proporcionar información sobre ubicaciones en Nariño (Pasto, Ipiales, Tumaco, etc.)
4. Sugerir eventos según preferencias del usuario

INSTRUCCIONES:
- Si te preguntan por eventos específicos, usa la información que te proporciono en el contexto
- Si no tienes información sobre un evento específico, sé honesto pero sugiere alternativas
- Mantén las respuestas concisas pero informativas (máximo 3-4 párrafos)
- Si te preguntan algo fuera de Nariño o eventos, redirige amablemente al tema
- Finaliza sugerencias con preguntas para mantener la conversación activa

IMPORTANTE:
- NO inventes eventos o fechas que no te proporcionen
- Si no sabes algo, admítelo y ofrece buscar en la app
- Mantén un balance entre ser útil y conciso
''';
  }

  Future<String> _getEventsContext() async {
    try {
      // Obtener eventos activos
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('state', isEqualTo: 'active')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date')
          .limit(10)
          .get();

      if (eventsSnapshot.docs.isEmpty) {
        return 'Actualmente no hay eventos registrados en el sistema.';
      }

      StringBuffer context = StringBuffer();
      context.writeln('EVENTOS ACTUALES EN NARIÑO:\n');

      for (var doc in eventsSnapshot.docs) {
        final event = EventModel.fromFirestore(doc);
        context.writeln('- ${event.title}');
        context.writeln('  Tipo: ${event.type}');
        context.writeln(
            '  Fecha: ${event.date.day}/${event.date.month}/${event.date.year}');
        context.writeln('  Hora: ${event.hour}');
        context.writeln('  Lugar: ${event.place}');
        context.writeln('  Precio: ${event.formattedPrice}');
        context.writeln('  Descripción: ${event.description}');
        context.writeln('');
      }

      return context.toString();
    } catch (e) {
      return 'No pude cargar la información de eventos en este momento.';
    }
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final eventsContext = await _getEventsContext();

      final fullMessage = '''
CONTEXTO DE EVENTOS:
$eventsContext

PREGUNTA DEL USUARIO:
$userMessage
''';

      final content = Content.text(fullMessage);

      final response = await _chat.sendMessage(content);

      return response.text ?? 'Lo siento, no pude generar una respuesta.';
    } on GenerativeAIException catch (e) {
      print('Error de Gemini AI: ${e.message}');

      if (e.message.contains('API key')) {
        return 'Hay un problema con la configuración del chatbot. Por favor contacta al administrador.';
      } else if (e.message.contains('quota')) {
        return 'El servicio está temporalmente no disponible. Intenta nuevamente en unos minutos.';
      } else if (e.message.contains('safety')) {
        return 'Tu mensaje contiene contenido que no puedo procesar. Por favor reformúlalo.';
      }

      return 'Disculpa, tuve un problema al procesar tu mensaje. ¿Podrías intentarlo de nuevo?';
    } catch (e) {
      print('Error inesperado al enviar mensaje: $e');
      return 'Disculpa, ocurrió un error inesperado. Por favor intenta nuevamente.';
    }
  }

  void resetConversation() {
    _chat = _model.startChat();
  }

  Future<void> saveMessage({
    required String userId,
    required ChatMessage message,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .add(message.toFirestore());
    } catch (e) {
      print('Error al guardar mensaje: $e');
    }
  }

  Stream<List<ChatMessage>> getChatHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .orderBy('timestamp', descending: false)
        .limit(50) // Últimos 50 mensajes
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  Future<void> clearChatHistory(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      resetConversation();
    } catch (e) {
      print('Error al limpiar historial: $e');
    }
  }

  static bool isConfigured() {
    return _apiKey != 'AIzaSyC4dbU4hos6mqVYRfmKNJh1WMeYohWpXE4' &&
        _apiKey.isNotEmpty;
  }
}
