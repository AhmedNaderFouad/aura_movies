abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}

class LoginNoInternet extends LoginState {
  const LoginNoInternet();
}

class LoginEmailNotVerified extends LoginState {
  const LoginEmailNotVerified();
}
