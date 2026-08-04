import '../datasources/local_auth_datasource.dart';
import '../datasources/remote_auth_datasource.dart';
import '../repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/apple_signin_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

class AuthService {
  static late AuthRepository _authRepository;
  static late LoginUseCase _loginUseCase;
  static late SignupUseCase _signupUseCase;
  static late LogoutUseCase _logoutUseCase;
  static late ForgotPasswordUseCase _forgotPasswordUseCase;
  static late GoogleSignInUseCase _googleSignInUseCase;
  static late AppleSignInUseCase _appleSignInUseCase;
  static late GetCurrentUserUseCase _getCurrentUserUseCase;

  /// Initialize all auth services
  static Future<void> initialize() async {
    // Initialize datasources
    final remoteDataSource = RemoteAuthDataSourceImpl();
    final localDataSource = LocalAuthDataSourceImpl(null);

    // Initialize repository
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    // Initialize use cases
    _loginUseCase = LoginUseCase(_authRepository);
    _signupUseCase = SignupUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _forgotPasswordUseCase = ForgotPasswordUseCase(_authRepository);
    _googleSignInUseCase = GoogleSignInUseCase(_authRepository);
    _appleSignInUseCase = AppleSignInUseCase(_authRepository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);

    // Handle "Remember me" - if not remembered, sign out on initialization
    if (!(await localDataSource.shouldRemember())) {
      await _authRepository.signOut();
    }
  }

  // Getters
  static AuthRepository get repository => _authRepository;
  static LoginUseCase get loginUseCase => _loginUseCase;
  static SignupUseCase get signupUseCase => _signupUseCase;
  static LogoutUseCase get logoutUseCase => _logoutUseCase;
  static ForgotPasswordUseCase get forgotPasswordUseCase =>
      _forgotPasswordUseCase;
  static GoogleSignInUseCase get googleSignInUseCase => _googleSignInUseCase;
  static AppleSignInUseCase get appleSignInUseCase => _appleSignInUseCase;
  static GetCurrentUserUseCase get getCurrentUserUseCase =>
      _getCurrentUserUseCase;
}
