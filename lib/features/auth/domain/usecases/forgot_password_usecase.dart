import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call({required String email}) async {
    final exists = await repository.checkIfEmailExists(email: email);
    if (!exists) {
      throw 'No account found with this email';
    }
    return await repository.resetPassword(email: email);
  }
}

