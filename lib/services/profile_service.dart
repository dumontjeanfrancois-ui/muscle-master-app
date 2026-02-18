import 'package:hive/hive.dart';
import 'dart:io';

class ProfileService {
  static const String _profileBoxName = 'profile';
  static const String _imageKey = 'profile_image';
  static const String _usernameKey = 'username';

  static Future<void> init() async {
    await Hive.openBox(_profileBoxName);
  }

  static Future<String?> getProfileImagePath() async {
    final box = await Hive.openBox(_profileBoxName);
    return box.get(_imageKey) as String?;
  }

  static Future<void> setProfileImagePath(String path) async {
    final box = await Hive.openBox(_profileBoxName);
    await box.put(_imageKey, path);
  }

  static Future<void> removeProfileImage() async {
    final box = await Hive.openBox(_profileBoxName);
    final imagePath = box.get(_imageKey) as String?;
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      await box.delete(_imageKey);
    }
  }

  static Future<String?> getUsername() async {
    final box = await Hive.openBox(_profileBoxName);
    return box.get(_usernameKey) as String?;
  }

  static Future<void> setUsername(String username) async {
    final box = await Hive.openBox(_profileBoxName);
    await box.put(_usernameKey, username);
  }

  static Future<void> clearProfile() async {
    final box = await Hive.openBox(_profileBoxName);
    await removeProfileImage();
    await box.clear();
  }
}
