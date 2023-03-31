import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth_error.dart';

abstract class AuthService {
  String? get userId;
  Future<bool> deleteAccAndSignOut();
  Future<void> signOut();
  Future<bool> register({
    required String email,
    required String password,
  });
  Future<bool> login({
    required String email,
    required String password,
  });
}

class FirebaseAuthService implements AuthService {
  @override
  Future<bool> deleteAccAndSignOut() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      // || Delete User
      await user.delete();
      // || Log User Out
      await auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      final authError = AuthError.from(e);
      throw authError;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> login({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthError.from(e);
    } catch (e) {
      rethrow;
    }

    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Future<bool> register({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthError.from(e);
    } catch (e) {
      rethrow;
    }

    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // || Ignoring Errors
    }
  }

  @override
  String? get userId => FirebaseAuth.instance.currentUser?.uid;
}
