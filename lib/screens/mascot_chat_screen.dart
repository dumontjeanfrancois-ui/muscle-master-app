import 'package:flutter/material.dart';
import '../services/mascot_chat_service.dart';
import '../services/mascot_service.dart';
import '../models/chat_message.dart';
import '../models/mascot_settings.dart';
import '../utils/theme.dart';

/// Écran de chat avec la mascotte
/// Interface conversationnelle pour poser des questions fitness/nutrition
class MascotChatScreen extends StatefulWidget {
  const MascotChatScreen({super.key});

  @override
  State<MascotChatScreen> createState() => _MascotChatScreenState();
}

class _MascotChatScreenState extends State<MascotChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late MascotSettings _mascotSettings;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _mascotSettings = MascotService.getSettings();
  }

  Future<void> _loadChatHistory() async {
    final history = await MascotChatService.getChatHistory();
    setState(() {
      _messages.addAll(history);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    _textController.clear();

    // Enregistrer l'interaction avec la mascotte
    await MascotService.recordInteraction();

    try {
      // Envoyer le message et obtenir une réponse
      final response = await MascotChatService.sendMessage(text);
      
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: text,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _messages.add(response);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'Effacer l\'historique',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment effacer tout l\'historique des conversations ?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Effacer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await MascotChatService.clearHistory();
      setState(() {
        _messages.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historique effacé'),
            backgroundColor: AppTheme.primaryOrange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Row(
          children: [
            if (_mascotSettings.mascotType != 'none')
              Image.asset(
                _mascotSettings.assetPath,
                height: 40,
                fit: BoxFit.contain,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat avec ${_mascotSettings.displayName}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Text(
                    'Coach virtuel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
            tooltip: 'Effacer l\'historique',
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone des messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                    strokeWidth: 2,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_mascotSettings.displayName} réfléchit...',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_mascotSettings.mascotType != 'none')
              Image.asset(
                _mascotSettings.assetPath,
                height: 150,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 24),
            Text(
              'Salut champion ! 🦁',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Je suis ${_mascotSettings.displayName}, ton coach virtuel !',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pose-moi des questions sur :\n\n'
              '💪 La musculation et les exercices\n'
              '🍽️ La nutrition et les macros\n'
              '😴 La récupération et le sommeil\n'
              '🎯 Tes objectifs fitness',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryOrange,
              backgroundImage: _mascotSettings.mascotType != 'none'
                  ? AssetImage(_mascotSettings.assetPath)
                  : null,
              child: _mascotSettings.mascotType == 'none'
                  ? const Icon(Icons.smart_toy, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryOrange
                    : AppTheme.cardDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Pose ta question...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppTheme.backgroundDark,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryOrange,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
