import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/gemini_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic>? _quota;

  @override
  void initState() {
    super.initState();
    _loadQuota();
    _addWelcomeMessage();
  }

  Future<void> _loadQuota() async {
    final quota = await GeminiService.checkQuota();
    setState(() {
      _quota = quota;
    });
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: "Yo ! 💪 Je suis ton coach IA personnel.\n\n"
            "Pose-moi n'importe quelle question sur :\n"
            "🏋️ Musculation & Entraînement\n"
            "🍽️ Nutrition & Macros\n"
            "💊 Supplémentation\n"
            "📈 Progression & Technique\n\n"
            "Balance ta question ! 🔥",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Ajouter le message utilisateur
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    // Scroll vers le bas
    _scrollToBottom();

    // Appeler l'API Gemini
    final response = await GeminiService.askCoach(userMessage);

    setState(() {
      _isLoading = false;

      if (response['success']) {
        // Ajouter la réponse du coach
        _messages.add(ChatMessage(
          text: response['answer'],
          isUser: false,
          timestamp: DateTime.now(),
        ));
        
        // Mettre à jour le quota
        _quota = response['quota'];
      } else {
        // Ajouter un message d'erreur
        _messages.add(ChatMessage(
          text: response['message'] ?? 'Une erreur est survenue.',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      }
    });

    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology_rounded, color: AppTheme.neonGreen),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COACH IA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen,
                  ),
                ),
                if (_quota != null)
                  Text(
                    '${_quota!['remaining']}/${_quota!['total']} questions restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: _quota!['remaining'] > 3 
                          ? AppTheme.textSecondary 
                          : AppTheme.neonOrange,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: AppTheme.neonBlue),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Indicateur de chargement
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.neonGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Coach en train d\'écrire...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Zone de saisie
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.neonGreen, AppTheme.neonBlue],
                ),
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: AppTheme.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.neonBlue.withOpacity(0.2)
                    : message.isError
                        ? AppTheme.neonOrange.withOpacity(0.2)
                        : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: message.isUser
                      ? AppTheme.neonBlue.withOpacity(0.5)
                      : message.isError
                          ? AppTheme.neonOrange.withOpacity(0.5)
                          : AppTheme.neonGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: AppTheme.textDisabled,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonBlue,
              ),
              child: Icon(
                Icons.person,
                color: AppTheme.primaryDark,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final hasQuota = _quota?['hasQuota'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.neonGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (!hasQuota)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.neonOrange.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: AppTheme.neonOrange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Limite atteinte ! Passez à Premium pour continuer 💎',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: hasQuota && !_isLoading,
                    decoration: InputDecoration(
                      hintText: hasQuota
                          ? 'Pose ta question au coach...'
                          : 'Limite atteinte',
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => hasQuota ? _sendMessage() : null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasQuota && !_isLoading
                        ? LinearGradient(
                            colors: [AppTheme.neonGreen, AppTheme.neonBlue],
                          )
                        : null,
                    color: !hasQuota || _isLoading
                        ? AppTheme.textDisabled
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: AppTheme.primaryDark,
                    ),
                    onPressed: hasQuota && !_isLoading ? _sendMessage : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            Icon(Icons.info_rounded, color: AppTheme.neonBlue),
            const SizedBox(width: 12),
            Text(
              'À propos du Coach IA',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version Gratuite :',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• ${GeminiService.FREE_QUESTIONS_PER_MONTH} questions par mois\n'
              '• Conseils personnalisés\n'
              '• Expertise musculation & nutrition',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Version Premium (9.99€/mois) :',
              style: TextStyle(
                color: AppTheme.neonOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Questions illimitées 💎\n'
              '• Programmes personnalisés\n'
              '• Analyse de progression\n'
              '• Support prioritaire',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.neonBlue)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
