import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _auth = AuthService();
  AppUser? user;
  bool loading = false;

  Future<bool> register(String email, String username, String password) async {
    loading = true;
    notifyListeners();
    final ok = await _auth.register(email, username, password);
    if (ok) user = await _auth.currentUser();
    loading = false;
    notifyListeners();
    return ok;
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    notifyListeners();
    final u = await _auth.login(email, password);
    user = u;
    loading = false;
    notifyListeners();
    return u != null;
  }

  Future<void> loadCurrentUser() async {
    user = await _auth.currentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    notifyListeners();
  }

  Future<void> saveUser() async {
    if (user != null) await _auth.saveUser(user!);
  }
}
