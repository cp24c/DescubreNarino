import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  late stt.SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isInitialized => _isInitialized;

  bool get isListening => _isListening;

  VoiceService() {
    _speech = stt.SpeechToText();
  }

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Error de voz: $error'),
        onStatus: (status) => print('Estado de voz: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('Error al inicializar voz: $e');
      return false;
    }
  }

  Future<bool> checkAvailability() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('No se pudo inicializar el reconocimiento de voz');
        return;
      }
    }

    if (_isListening) {
      print('Ya está escuchando');
      return;
    }

    try {
      _isListening = true;

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            stopListening();
          }
        },
        listenFor: const Duration(seconds: 30), // Máximo 30 segundos
        pauseFor: const Duration(seconds: 3), // Pausa de 3 segundos
        partialResults: false, // Solo resultados finales
        localeId: 'es_ES', // Español
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      _isListening = false;
      print('Error al iniciar escucha: $e');
      onError?.call('Error al iniciar reconocimiento de voz: $e');
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> cancel() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speech.locales();
  }

  void dispose() {
    _speech.stop();
    _isListening = false;
  }
}
