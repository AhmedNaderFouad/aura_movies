import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  });

  /// Create account with email and password
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    bool rememberMe = true,
  });

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle({bool rememberMe = true});

  /// Sign in with Apple
  Future<UserEntity> signInWithApple({bool rememberMe = true});

  /// Forgot password
  Future<void> resetPassword({required String email});

  /// Check if email exists
  Future<bool> checkIfEmailExists({required String email});

  /// Sign out
  Future<void> signOut();

  /// Get current logged-in user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isUserLoggedIn();

  /// Listen to authentication state changes
  Stream<UserEntity?> authStateChanges();
}
