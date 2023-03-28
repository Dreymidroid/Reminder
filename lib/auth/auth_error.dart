import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/utils/extensions.dart';
import 'package:flutter/foundation.dart' show immutable;

const Map<String, AuthError> authErrorMapping = {
  'user-not-found': AuthErrorUserNotFound(),
  'weak-password': AuthErrorWeakPassword(),
  'invalid-email': AuthErrorInvalidEmail(),
  'operation-not-allowed': AuthErrorOperationNotAllowed(), 
  'email-already-in-use': AuthErrorEmailAlreadyInUse(),
  'required-recent-login': AuthErrorNoRequiresRecentLogin(),
  'no-current-user': AuthErrorNoCurrentUser(),
};

@immutable
abstract class AuthError {
  final String dialogTitle;
  final String dialogText;

  const AuthError({
    required this.dialogText,
    required this.dialogTitle,
  });

  factory AuthError.from(FirebaseAuthException exception) =>
      authErrorMapping[exception.code.toLowerCase().trim()] ??
      AuthErrorUnknown(exception);
}

@immutable
class AuthErrorUnknown extends AuthError {
  final FirebaseAuthException innerException;
  AuthErrorUnknown(this.innerException)
      : super(
          dialogText: innerException.code.processedText,
          dialogTitle: "Authentication Error",
        );
}

@immutable
class AuthErrorNoCurrentUser extends AuthError {
  const AuthErrorNoCurrentUser()
      : super(
          dialogText: "There is no user present",
          dialogTitle: "No Current User",
        );
}

@immutable
class AuthErrorNoRequiresRecentLogin extends AuthError {
  const AuthErrorNoRequiresRecentLogin()
      : super(
          dialogText: "Requires Recent Login",
          dialogTitle:
              "The operation requires recent login please log out and back in",
        );
}

// Using a disabled sign in method
@immutable
class AuthErrorOperationNotAllowed extends AuthError {
  const AuthErrorOperationNotAllowed()
      : super(
          dialogText: "Operation Not Allowed",
          dialogTitle: "This operation not allowed",
        );
}

@immutable
class AuthErrorUserNotFound extends AuthError {
  const AuthErrorUserNotFound()
      : super(
          dialogText: "There is no user present",
          dialogTitle: "No Current User",
        );
}

@immutable
class AuthErrorWeakPassword extends AuthError {
  const AuthErrorWeakPassword()
      : super(
          dialogText: "Weak Password",
          dialogTitle: "Type a stronger password",
        );
}

@immutable
class AuthErrorInvalidEmail extends AuthError {
  const AuthErrorInvalidEmail()
      : super(
          dialogText: "Invalid Email",
          dialogTitle: "Please enter a valid email",
        );
}

@immutable
class AuthErrorEmailAlreadyInUse extends AuthError {
  const AuthErrorEmailAlreadyInUse()
      : super(
          dialogText: "Email Already In Use",
          dialogTitle: "This email is already in use please login",
        );
}
