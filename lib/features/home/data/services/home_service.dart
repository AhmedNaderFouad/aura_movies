import '../../../auth/data/services/auth_service.dart';
import '../../../auth/domain/entities/user_entity.dart';

class HomeService {
  /// Get current logged-in user
  static Future<UserEntity?> getCurrentUser() async {
    return await AuthService.getCurrentUserUseCase.call();
  }

  /// Logout current user
  static Future<void> logout() async {
    return await AuthService.logoutUseCase.call();
  }
}
