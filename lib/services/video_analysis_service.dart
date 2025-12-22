import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_analysis.dart';

class VideoAnalysisService {
  static const String _storageKey = 'video_analyses';

  // Sauvegarder une nouvelle analyse
  Future<void> saveAnalysis(VideoAnalysis analysis) async {
    final prefs = await SharedPreferences.getInstance();
    final analyses = await getAnalyses();
    analyses.add(analysis);
    
    final jsonList = analyses.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Récupérer toutes les analyses
  Future<List<VideoAnalysis>> getAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => VideoAnalysis.fromJson(json)).toList();
  }

  // Supprimer une analyse
  Future<void> deleteAnalysis(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final analyses = await getAnalyses();
    analyses.removeWhere((a) => a.id == id);
    
    final jsonList = analyses.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Obtenir une analyse spécifique
  Future<VideoAnalysis?> getAnalysis(String id) async {
    final analyses = await getAnalyses();
    try {
      return analyses.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
