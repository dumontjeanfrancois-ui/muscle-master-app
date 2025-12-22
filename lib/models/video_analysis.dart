class VideoAnalysis {
  final String id;
  final String videoPath;
  final DateTime recordedAt;
  final String? exerciseName;
  final Map<String, dynamic>? analysisResults;

  VideoAnalysis({
    required this.id,
    required this.videoPath,
    required this.recordedAt,
    this.exerciseName,
    this.analysisResults,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoPath': videoPath,
        'recordedAt': recordedAt.toIso8601String(),
        'exerciseName': exerciseName,
        'analysisResults': analysisResults,
      };

  factory VideoAnalysis.fromJson(Map<String, dynamic> json) => VideoAnalysis(
        id: json['id'] as String,
        videoPath: json['videoPath'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        exerciseName: json['exerciseName'] as String?,
        analysisResults: json['analysisResults'] as Map<String, dynamic>?,
      );
}
