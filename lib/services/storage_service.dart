import 'package:hive/hive.dart';
import '../models/user.dart';

class StorageService {
  static const String usersBox = 'usersBox';

  Future<void> init() async {
    await Hive.openBox(usersBox);
  }

  Future<AppUser?> getUser(String email) async {
    final box = Hive.box(usersBox);
    if (!box.containsKey(email)) return null;
    final data = Map<String, dynamic>.from(box.get(email));
    return AppUser.fromJson(data);
  }

  Future<void> saveUser(AppUser user) async {
    final box = Hive.box(usersBox);
    await box.put(user.email, user.toJson());
  }

  Future<void> setCurrentUserEmail(String email) async {
    final box = Hive.box(usersBox);
    await box.put('__current__', email);
  }

  String? getCurrentUserEmail() {
    final box = Hive.box(usersBox);
    return box.get('__current__');
  }

  Future<void> logout() async {
    final box = Hive.box(usersBox);
    await box.delete('__current__');
  }
}
