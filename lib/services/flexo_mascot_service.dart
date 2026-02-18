import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

/// Service de gestion de la mascotte Flexo
class FlexoMascotService {
  static final FlexoMascotService _instance = FlexoMascotService._internal();
  factory FlexoMascotService() => _instance;
  FlexoMascotService._internal();

  final ValueNotifier<FlexoState> stateNotifier = ValueNotifier(FlexoState());
  Timer? _moveTimer;
  Timer? _messageTimer;

  /// Démarrer l'animation de la mascotte
  void start() {
    // Déplacement aléatoire toutes les 5-8 secondes
    _moveTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _randomMove();
    });

    // Afficher un message toutes les 15-30 secondes
    _messageTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      showRandomMessage();
    });
  }

  /// Arrêter l'animation
  void stop() {
    _moveTimer?.cancel();
    _messageTimer?.cancel();
  }

  /// Déplacement aléatoire
  void _randomMove() {
    final random = Random();
    final state = stateNotifier.value;
    
    stateNotifier.value = state.copyWith(
      position: Offset(
        random.nextDouble() * 0.8 + 0.1, // 10% à 90% de la largeur
        random.nextDouble() * 0.8 + 0.1, // 10% à 90% de la hauteur
      ),
      isMoving: true,
    );

    // Arrêter l'animation de mouvement après 1 seconde
    Future.delayed(const Duration(milliseconds: 1000), () {
      final currentState = stateNotifier.value;
      stateNotifier.value = currentState.copyWith(isMoving: false);
    });
  }

  /// Afficher un message aléatoire
  void showRandomMessage() {
    final random = Random();
    final messages = FlexoMessages.getAllMessages();
    final message = messages[random.nextInt(messages.length)];

    final state = stateNotifier.value;
    stateNotifier.value = state.copyWith(
      currentMessage: message,
      showMessage: true,
    );

    // Cacher le message après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      final currentState = stateNotifier.value;
      stateNotifier.value = currentState.copyWith(showMessage: false);
    });
  }

  /// Afficher un message spécifique
  void showMessage(FlexoMessage message) {
    final state = stateNotifier.value;
    stateNotifier.value = state.copyWith(
      currentMessage: message,
      showMessage: true,
    );

    Future.delayed(const Duration(seconds: 5), () {
      final currentState = stateNotifier.value;
      stateNotifier.value = currentState.copyWith(showMessage: false);
    });
  }

  /// Cacher la mascotte
  void hide() {
    final state = stateNotifier.value;
    stateNotifier.value = state.copyWith(isVisible: false);
  }

  /// Afficher la mascotte
  void show() {
    final state = stateNotifier.value;
    stateNotifier.value = state.copyWith(isVisible: true);
  }
}

/// État de la mascotte Flexo
class FlexoState {
  final Offset position;
  final bool isMoving;
  final bool showMessage;
  final FlexoMessage? currentMessage;
  final bool isVisible;

  FlexoState({
    this.position = const Offset(0.8, 0.8), // Coin bas-droit par défaut
    this.isMoving = false,
    this.showMessage = false,
    this.currentMessage,
    this.isVisible = true,
  });

  FlexoState copyWith({
    Offset? position,
    bool? isMoving,
    bool? showMessage,
    FlexoMessage? currentMessage,
    bool? isVisible,
  }) {
    return FlexoState(
      position: position ?? this.position,
      isMoving: isMoving ?? this.isMoving,
      showMessage: showMessage ?? this.showMessage,
      currentMessage: currentMessage ?? this.currentMessage,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Message de la mascotte
class FlexoMessage {
  final String text;
  final String? actionRoute; // Route à naviguer si cliqué
  final IconData icon;

  FlexoMessage({
    required this.text,
    this.actionRoute,
    this.icon = Icons.help_outline,
  });
}

/// Base de données de messages de Flexo
class FlexoMessages {
  // Messages d'aide pour trouver les fonctionnalités
  static List<FlexoMessage> get helpMessages => [
    FlexoMessage(
      text: "Besoin d'aide pour trouver le journal alimentaire ? C'est dans l'onglet Nutrition ! 🍽️",
      actionRoute: '/nutrition',
      icon: Icons.restaurant,
    ),
    FlexoMessage(
      text: "Tu cherches les programmes d'entraînement ? Va dans l'onglet Programmes ! 💪",
      actionRoute: '/programs',
      icon: Icons.fitness_center,
    ),
    FlexoMessage(
      text: "Besoin de créer un programme personnalisé ? Utilise le Générateur IA ! 🤖",
      actionRoute: '/ai_program_generator',
      icon: Icons.auto_awesome,
    ),
    FlexoMessage(
      text: "Tu veux voir tes statistiques ? C'est dans l'onglet Suivi ! 📊",
      actionRoute: '/progress',
      icon: Icons.trending_up,
    ),
    FlexoMessage(
      text: "Cherche des exercices ? Va dans la Bibliothèque d'exercices ! 🏋️",
      actionRoute: '/exercise_library',
      icon: Icons.library_books,
    ),
    FlexoMessage(
      text: "Besoin de calculer tes macros ? Utilise le Calculateur dans Nutrition ! 🔢",
      actionRoute: '/macro_calculator',
      icon: Icons.calculate,
    ),
    FlexoMessage(
      text: "Tu veux parler au Coach IA ? Clique sur l'onglet Coach ! 🤖",
      actionRoute: '/ai_coach',
      icon: Icons.chat,
    ),
  ];

  // Messages de motivation
  static List<FlexoMessage> get motivationMessages => [
    FlexoMessage(
      text: "Continue comme ça ! Tu es sur la bonne voie ! 💪",
      icon: Icons.emoji_events,
    ),
    FlexoMessage(
      text: "N'oublie pas de bien t'hydrater ! 💧",
      icon: Icons.local_drink,
    ),
    FlexoMessage(
      text: "Le repos est aussi important que l'entraînement ! 😴",
      icon: Icons.bedtime,
    ),
    FlexoMessage(
      text: "Pense à varier tes exercices ! 🔄",
      icon: Icons.repeat,
    ),
    FlexoMessage(
      text: "As-tu enregistré ton repas d'aujourd'hui ? 🍽️",
      icon: Icons.restaurant,
    ),
    FlexoMessage(
      text: "La constance est la clé du succès ! 🔑",
      icon: Icons.check_circle,
    ),
    FlexoMessage(
      text: "Chaque jour est une nouvelle chance de progresser ! 🌟",
      icon: Icons.star,
    ),
  ];

  // Tous les messages
  static List<FlexoMessage> getAllMessages() {
    return [...helpMessages, ...motivationMessages];
  }
}
