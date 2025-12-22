import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 6)
class AppUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password; // En production, utiliser un hash sécurisé

  @HiveField(3)
  String name;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? lastLogin;

  @HiveField(6)
  bool isLoggedIn;

  AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    this.lastLogin,
    this.isLoggedIn = false,
  });
}
