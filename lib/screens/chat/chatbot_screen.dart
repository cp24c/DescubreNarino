import 'package:descubre_narino/constants/colors.dart';
import 'package:descubre_narino/models/chat_message_model.dart';
import 'package:descubre_narino/providers/auth_provider.dart';
import 'package:descubre_narino/services/chatbot_service.dart';
import 'package:descubre_narino/services/voice_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  String _recognizedText = '';
  bool _showVoiceOverlay = false;
  final ChatbotService _chatbotService = ChatbotService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeVoice();
    _addWelcomeMessage();
  }

  Future<void> _initializeVoice() async {
    await _voiceService.initialize();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().toString(),
      text:
          '¡Hola! 👋 Soy NariñoBot, tu asistente para descubrir eventos increíbles en Nariño. ¿En qué puedo ayudarte hoy?',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      userId: userId,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    if (userId != null) {
      await _chatbotService.saveMessage(userId: userId, message: userMessage);
    }

    try {
      final botResponse = await _chatbotService.sendMessage(text);

      final botMessage = ChatMessage(
        id: DateTime.now().toString(),
        text: botResponse,
        isUser: false,
        timestamp: DateTime.now(),
        userId: userId,
      );

      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });

      if (userId != null) {
        await _chatbotService.saveMessage(userId: userId, message: botMessage);
      }

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar('Error al enviar mensaje. Intenta nuevamente.');
    }
  }

  Future<void> _startVoiceRecognition() async {
    final hasPermission = await _voiceService.checkAvailability();

    if (!hasPermission) {
      _showErrorSnackBar(
          'No se pudo acceder al micrófono. Verifica los permisos.');
      return;
    }

    setState(() {
      _isListening = true;
      _showVoiceOverlay = true;
      _recognizedText = '';
    });

    await _voiceService.startListening(
      onResult: (recognizedText) {
        setState(() {
          _recognizedText = recognizedText;
        });
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _showVoiceOverlay = false;
        });
        _showErrorSnackBar('Error de reconocimiento de voz: $error');
      },
    );
  }

  Future<void> _stopVoiceRecognition() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  void _cancelVoiceRecognition() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
      _showVoiceOverlay = false;
      _recognizedText = '';
    });
  }

  void _sendVoiceText() async {
    if (_recognizedText.trim().isEmpty) {
      _showErrorSnackBar('No se detectó ningún texto');
      return;
    }

    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
      _showVoiceOverlay = false;
    });

    _sendMessage(_recognizedText);
    setState(() {
      _recognizedText = '';
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? AppColorsDark.error : AppColors.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Limpiar Conversación',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('¿Deseas eliminar todo el historial de conversación?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _chatbotService.resetConversation();
                _addWelcomeMessage();
              });
              Navigator.pop(context);
            },
            child: Text('Limpiar', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDark ? AppColorsDark.background : AppColors.background;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.white;
    final textColor = isDark ? AppColorsDark.darkText : AppColors.darkText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 2,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NariñoBot',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Tu asistente de eventos',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: textColor),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 80, color: primaryColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Inicia una conversación',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Indicador de carga
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  CircularProgressIndicator(
                      strokeWidth: 2, color: primaryColor),
                  const SizedBox(width: 12),
                  Text('NariñoBot está escribiendo...',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: textColor.withOpacity(0.6))),
                ],
              ),
            ),

          // Overlay de reconocimiento de voz
          if (_showVoiceOverlay) _buildVoiceOverlay(),
          // Campo de entrada
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.white;
    final textColor = isDark ? AppColorsDark.darkText : AppColors.darkText;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: message.isUser
                ? (isDark ? Colors.black : Colors.white)
                : textColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.white;
    final textColor = isDark ? AppColorsDark.darkText : AppColors.darkText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de voz
          Container(
            decoration: BoxDecoration(
              color:
                  _isListening ? primaryColor : primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening
                    ? (isDark ? Colors.black : Colors.white)
                    : primaryColor,
              ),
              onPressed:
                  _isListening ? _stopVoiceRecognition : _startVoiceRecognition,
            ),
          ),
          const SizedBox(width: 12),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.poppins(color: textColor),
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta...',
                hintStyle:
                    GoogleFonts.poppins(color: textColor.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: (isDark
                    ? AppColorsDark.surfaceVariant
                    : Colors.grey.shade100),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: _sendMessage,
              enabled: !_isLoading && !_isListening,
            ),
          ),

          const SizedBox(width: 12),

          // Botón enviar
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColorsDark.primaryGradient
                  : AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon:
                  Icon(Icons.send, color: isDark ? Colors.black : Colors.white),
              onPressed: _isLoading || _isListening
                  ? null
                  : () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceOverlay() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.white;
    final textColor = isDark ? AppColorsDark.darkText : AppColors.darkText;
    final errorColor = isDark ? AppColorsDark.error : AppColors.error;
    final successColor = isDark ? AppColorsDark.success : AppColors.success;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Indicador de grabación
          Row(
            children: [
              Icon(
                Icons.mic,
                color: _isListening ? errorColor : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isListening ? 'Escuchando...' : 'Procesando...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_isListening)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Texto reconocido
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColorsDark.surfaceVariant : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _recognizedText.isEmpty ? 'Habla ahora...' : _recognizedText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _recognizedText.isEmpty
                    ? textColor.withOpacity(0.5)
                    : textColor,
                fontStyle: _recognizedText.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Cancelar (X)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: errorColor),
                    onPressed: _cancelVoiceRecognition,
                    tooltip: 'Cancelar',
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Botón Enviar (Flecha arriba en círculo)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColorsDark.primaryGradient
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                    onPressed: _sendVoiceText,
                    tooltip: 'Enviar mensaje',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
