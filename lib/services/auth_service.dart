import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _store = StorageService();

  Future<bool> register(String email, String username, String password) async {
    final existing = await _store.getUser(email);
    if (existing != null) return false;
    final u = AppUser(email: email, username: username, password: password);
    await _store.saveUser(u);
    await _store.setCurrentUserEmail(email);
    return true;
  }

  Future<AppUser?> login(String email, String password) async {
    final u = await _store.getUser(email);
    if (u == null) return null;
    if (u.password == password) {
      await _store.setCurrentUserEmail(email);
      return u;
    }
    return null;
  }

  Future<AppUser?> currentUser() async {
    final email = _store.getCurrentUserEmail();
    if (email == null) return null;
    return _store.getUser(email);
  }

  Future<void> logout() async {
    await _store.logout();
  }

  Future<void> saveUser(AppUser u) async => _store.saveUser(u);
}
