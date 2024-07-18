abstract class ForgottenPasswordState {}

class ForgottenPasswordInitial extends ForgottenPasswordState {}

class ForgottenPasswordSuccess extends ForgottenPasswordState {}

class ForgottenPasswordError extends ForgottenPasswordState {
  final String errorMessage;

  ForgottenPasswordError(this.errorMessage);
}
