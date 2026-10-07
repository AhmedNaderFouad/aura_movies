import '../../../../core/di/service_locator.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/apple_signin_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

class AuthService {
  static Future<void> initialize() async {}

  static AuthRepository get repository => sl<AuthRepository>();
  static LoginUseCase get loginUseCase => sl<LoginUseCase>();
  static SignupUseCase get signupUseCase => sl<SignupUseCase>();
  static LogoutUseCase get logoutUseCase => sl<LogoutUseCase>();
  static ForgotPasswordUseCase get forgotPasswordUseCase =>
      sl<ForgotPasswordUseCase>();
  static GoogleSignInUseCase get googleSignInUseCase =>
      sl<GoogleSignInUseCase>();
  static AppleSignInUseCase get appleSignInUseCase => sl<AppleSignInUseCase>();
  static GetCurrentUserUseCase get getCurrentUserUseCase =>
      sl<GetCurrentUserUseCase>();
}
