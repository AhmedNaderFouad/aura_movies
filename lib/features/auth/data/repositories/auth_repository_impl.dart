import '../datasources/local_auth_datasource.dart';
import '../datasources/remote_auth_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource remoteDataSource;
  final LocalAuthDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final user = await remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    await localDataSource.saveUser(user, rememberMe: rememberMe);
    return user;
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    bool rememberMe = true,
  }) async {
    final user = await remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
    await localDataSource.saveUser(user, rememberMe: rememberMe);
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle({bool rememberMe = true}) async {
    final user = await remoteDataSource.signInWithGoogle();
    await localDataSource.saveUser(user, rememberMe: rememberMe);
    return user;
  }

  @override
  Future<UserEntity> signInWithApple({bool rememberMe = true}) async {
    final user = await remoteDataSource.signInWithApple();
    await localDataSource.saveUser(user, rememberMe: rememberMe);
    return user;
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await remoteDataSource.resetPassword(email: email);
  }

  @override
  Future<bool> checkIfEmailExists({required String email}) async {
    return await remoteDataSource.checkIfEmailExists(email: email);
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = remoteDataSource.getCurrentUser();
      if (user != null) {
        final shouldRemember = await localDataSource.shouldRemember();
        await localDataSource.saveUser(user, rememberMe: shouldRemember);
        return user;
      }
      // If no remote user, check local
      return await localDataSource.getUser();
    } catch (e) {
      // If remote fails, try local
      return await localDataSource.getUser();
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final user = remoteDataSource.getCurrentUser();
      if (user != null) {
        return true;
      }
      return await localDataSource.hasUser();
    } catch (e) {
      return await localDataSource.hasUser();
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return remoteDataSource.authStateChanges().asyncMap((user) async {
      if (user != null) {
        final shouldRemember = await localDataSource.shouldRemember();
        await localDataSource.saveUser(user, rememberMe: shouldRemember);
      } else {
        await localDataSource.clearUser();
      }
      return user;
    });
  }
}


