/// Map des vidéos YouTube pour chaque exercice
/// Format: exerciseId -> YouTube Video ID
class ExerciseVideos {
  static const Map<String, String> videoIds = {
    // PECTORAUX
    'bench_press': 'rT7DgCr-3pg',  // Bench Press Tutorial
    'incline_bench_press': 'SrqOu55lrYU',  // Incline Bench Press
    'decline_bench_press': '0G2_XV7slIg',  // Decline Bench Press
    'dumbbell_press': '622ku8i0M14',  // Dumbbell Bench Press
    'dumbbell_flyes': 'eozdVDA78K0',  // Dumbbell Flyes
    'push_up': 'IODxDxX7oi4',  // Perfect Push Up
    'chest_dips': '2z8JmcrW-As',  // Chest Dips
    'cable_crossover': 'taI4XduLpTk',  // Cable Crossover
    
    // DORSAUX
    'pull_up': 'eGo4IYlbE5g',  // Pull Ups Tutorial
    'chin_up': 'brhRXlOhkLA',  // Chin Ups
    'barbell_row': 'FWJR5Ve8bnQ',  // Barbell Row
    'dumbbell_row': 'roCP6wCXPqo',  // Dumbbell Row
    'lat_pulldown': 'CAwf7n6Luuc',  // Lat Pulldown
    'seated_cable_row': 'UCXxvVItLoM',  // Seated Row
    'deadlift': 'ytGaGIn3SjE',  // Deadlift Tutorial
    't_bar_row': '6FzSTHThqL8',  // T-Bar Row
    
    // JAMBES
    'squat': 'ultWZbUMPL8',  // Squat Tutorial
    'front_squat': 'uYumuL_G_V0',  // Front Squat
    'leg_press': 'IZxyjW7MPJQ',  // Leg Press
    'leg_extension': 'YyvSfVjQeL0',  // Leg Extension
    'leg_curl': 'ELOCsoDSmrg',  // Leg Curl
    'lunges': 'QOVaHwm-Q6U',  // Lunges
    'bulgarian_split_squat': '2C-uNgKwPLE',  // Bulgarian Split Squat
    'romanian_deadlift': 'CQp5I9KgdXI',  // Romanian Deadlift
    'hip_thrust': 'xDmFkJxPzeM',  // Hip Thrust
    'calf_raise': 'gwLzBJYoWlI',  // Calf Raises
    
    // ÉPAULES
    'military_press': 'qEwKCR5JCog',  // Military Press
    'arnold_press': 'tR9ynaZ8Q1g',  // Arnold Press
    'lateral_raise': '3VcKaXpzqRo',  // Lateral Raises
    'front_raise': 'cl2RbrmL4cY',  // Front Raises
    'rear_delt_fly': 'ea7KoVNSvZA',  // Rear Delt Fly
    'face_pull': 'rep-qVOkqgk',  // Face Pulls
    'upright_row': '5BRm4fmtT3w',  // Upright Row
    
    // BICEPS
    'barbell_curl': 'ykJmrZ5v0Oo',  // Barbell Curl
    'dumbbell_curl': 'sAq_ocpRh_I',  // Dumbbell Curl
    'hammer_curl': 'zC3nLlEvin4',  // Hammer Curl
    'preacher_curl': 'fIWP-FRFNU0',  // Preacher Curl
    'concentration_curl': 'Jvj3uqJJhKI',  // Concentration Curl
    'cable_curl': 'NFzTWp2qpiw',  // Cable Curl
    
    // TRICEPS
    'tricep_dips': '6kALZikXxLc',  // Tricep Dips
    'overhead_extension': 'nRiJVZDpdL0',  // Overhead Extension
    'skull_crusher': 'QNg0wdPBTmQ',  // Skull Crushers
    'rope_pushdown': 'LQp0KMpqTjA',  // Rope Pushdown
    'kickback': 'kI-6UG19Hys',  // Kickback
    'close_grip_bench': 'nEF0bv2FW94',  // Close Grip Bench
    
    // ABDOMINAUX
    'crunch': 'Xyd_fa5zoEU',  // Crunches
    'leg_raise': '8JT7mbgxgHs',  // Leg Raises
    'plank': 'ASdvN_XEl_c',  // Plank
    'side_plank': 'K2VljzCC16g',  // Side Plank
    'russian_twist': 'wkD8rjkodUI',  // Russian Twist
    'bicycle_crunch': '9FGilxCbdz8',  // Bicycle Crunch
    'mountain_climber': 'nmwgirgXLYM',  // Mountain Climbers
    'ab_wheel': 'uwiIXLbJHMI',  // Ab Wheel
    
    // CARDIO
    'running': 'brFHyOtTwH4',  // Running Form
    'cycling': 'XbUVlvIvVqA',  // Cycling
    'rowing': '3p-RvfnwrEE',  // Rowing Machine
    'jump_rope': 'FJmRQ5iTXKE',  // Jump Rope
    'burpees': 'dZgVxmf6jkA',  // Burpees
    'jumping_jacks': '0xNmKF-zrRk',  // Jumping Jacks
    
    // EXERCICES AVANCÉS
    'muscle_up': '7Gp4LLV_RQI',  // Muscle Up
    'handstand_pushup': 'vQaXpJplCZo',  // Handstand Push Up
    'pistol_squat': 't7Oj8-8Htyw',  // Pistol Squat
    'l_sit': 'IUZJoSP66HI',  // L-Sit
    'dragon_flag': 'moyFIvRrS0s',  // Dragon Flag
    
    // FONCTIONNEL
    'kettlebell_swing': 'YSxHifyI6s8',  // Kettlebell Swing
    'turkish_getup': 'IlFzlXCAfao',  // Turkish Get Up
    'clean_and_press': 'KwYJTpQ_x5A',  // Clean and Press
    'box_jump': 'hxldG9FX4j4',  // Box Jumps
    'farmers_walk': 'WCSaqjKVPz8',  // Farmer's Walk
    
    // MOBILITÉ
    'hamstring_stretch': 'UgsRIbEWGmc',  // Hamstring Stretch
    'quad_stretch': '0_fONTqzVPE',  // Quad Stretch
    'yoga_flow': 'v7AYKMP6rOE',  // Yoga Flow
    'foam_rolling': 'vNDYxIMjlKw',  // Foam Rolling
  };
  
  /// Obtenir l'URL complète YouTube pour un exercice
  static String? getVideoUrl(String exerciseId) {
    final videoId = videoIds[exerciseId];
    if (videoId == null || videoId.isEmpty) return null;
    return 'https://www.youtube.com/watch?v=$videoId';
  }
  
  /// Obtenir l'URL d'embed YouTube pour un exercice
  static String? getEmbedUrl(String exerciseId) {
    final videoId = videoIds[exerciseId];
    if (videoId == null || videoId.isEmpty) return null;
    return 'https://www.youtube.com/embed/$videoId';
  }
  
  /// Obtenir l'URL de la miniature YouTube pour un exercice
  static String? getThumbnailUrl(String exerciseId) {
    final videoId = videoIds[exerciseId];
    if (videoId == null || videoId.isEmpty) return null;
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}
