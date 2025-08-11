import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class UserController extends ChangeNotifier {
  final StorageService _store = StorageService();
  AppUser? user;

  Future<void> load(String email) async {
    user = await _store.getUser(email);
    notifyListeners();
  }

  Future<void> addAllergy(String a) async {
    if (user == null) return;
    user!.allergies.add(a);
    await _store.saveUser(user!);
    notifyListeners();
  }

  Future<void> removeAllergy(String a) async {
    if (user == null) return;
    user!.allergies.remove(a);
    await _store.saveUser(user!);
    notifyListeners();
  }

  Future<void> toggleFavorite(String mealId) async {
    if (user == null) return;
    if (user!.favorites.contains(mealId)) {
      user!.favorites.remove(mealId);
    } else {
      user!.favorites.add(mealId);
    }
    await _store.saveUser(user!);
    notifyListeners();
  }
}
