import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AppleSignInUseCase {
  final AuthRepository repository;

  AppleSignInUseCase(this.repository);

  Future<UserEntity> call({bool rememberMe = true}) async {
    return await repository.signInWithApple(rememberMe: rememberMe);
  }
}
