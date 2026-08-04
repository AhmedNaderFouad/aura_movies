import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

abstract class LocalAuthDataSource {
  /// Save user locally
  Future<void> saveUser(UserModel user, {bool rememberMe = true});

  /// Get saved user
  Future<UserModel?> getUser();

  /// Clear saved user
  Future<void> clearUser();

  /// Check if user exists locally
  Future<bool> hasUser();

  /// Check if user should be remembered
  Future<bool> shouldRemember();
}

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  static const String _userKey = 'auth_user';
  static const String _rememberMeKey = 'remember_me';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  LocalAuthDataSourceImpl(dynamic preferences);

  @override
  Future<void> saveUser(UserModel user, {bool rememberMe = true}) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: _userKey, value: userJson);
    await _secureStorage.write(
      key: _rememberMeKey,
      value: rememberMe.toString(),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final rememberMeStr = await _secureStorage.read(key: _rememberMeKey);
    // Default to true if not set
    final rememberMe = rememberMeStr == null || rememberMeStr == 'true';
    if (!rememberMe) return null;

    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(userJson);
        return UserModel.fromJson(decoded);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await _secureStorage.delete(key: _userKey);
    await _secureStorage.delete(key: _rememberMeKey);
  }

  @override
  Future<bool> hasUser() async {
    return await _secureStorage.containsKey(key: _userKey);
  }

  @override
  Future<bool> shouldRemember() async {
    final rememberMeStr = await _secureStorage.read(key: _rememberMeKey);
    // Default to true if not set
    return rememberMeStr == null || rememberMeStr == 'true';
  }
}
