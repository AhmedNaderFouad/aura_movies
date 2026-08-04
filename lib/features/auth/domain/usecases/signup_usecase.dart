import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
    bool rememberMe = true,
  }) async {
    return await repository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      rememberMe: rememberMe,
    );
  }
}
