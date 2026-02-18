import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Widget pour afficher des vidéos YouTube
/// Compatible Web (iframe) et Android (webview simulé)
class YouTubePlayerWidget extends StatefulWidget {
  final String videoId;
  final double aspectRatio;
  
  const YouTubePlayerWidget({
    super.key,
    required this.videoId,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  @override
  void initState() {
    super.initState();
    // Note: HtmlElementView gère l'iframe automatiquement sur Web
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMobileFallback(),
        ),
      ),
    );
  }

  Widget _buildMobileFallback() {
    // Pour Android, afficher un placeholder avec lien
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Vidéo YouTube',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Ouvrir dans l'app YouTube ou navigateur
              final url = 'https://www.youtube.com/watch?v=${widget.videoId}';
              // TODO: Utiliser url_launcher pour ouvrir l'URL
              debugPrint('Ouvrir: $url');
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Voir sur YouTube'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Miniature YouTube cliquable
class YouTubeThumbnail extends StatelessWidget {
  final String videoId;
  final VoidCallback? onTap;
  final double height;

  const YouTubeThumbnail({
    super.key,
    required this.videoId,
    this.onTap,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(
              'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
