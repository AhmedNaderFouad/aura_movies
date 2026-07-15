import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/services/auth_service.dart';

/// Auth State Notifier for managing authentication state globally
class AuthStateNotifier extends ChangeNotifier {
  UserEntity? _currentUser;

  UserEntity? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthStateNotifier() {
    _initializeAuth();
  }

  /// Initialize authentication on app startup
  Future<void> _initializeAuth() async {
    try {
      final user = await AuthService.getCurrentUserUseCase.call();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Update user after login
  void setUser(UserEntity? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Clear user on logout
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  /// Listen to auth state changes
  void listenToAuthChanges() {
    AuthService.repository.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }
}


