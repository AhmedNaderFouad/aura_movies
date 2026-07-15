import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<UserEntity> call({bool rememberMe = true}) async {
    return await repository.signInWithGoogle(rememberMe: rememberMe);
  }
}

