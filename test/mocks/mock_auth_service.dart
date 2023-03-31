import 'package:first/services/auth_services.dart';

import '../utils.dart';

class MockAuthService implements AuthService {
  @override
  Future<bool> deleteAccAndSignOut() => true.toFuture(oneSecond);

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) => true.toFuture(oneSecond);

  @override
  Future<bool> register({
    required String email,
    required String password,
  }) => true.toFuture(oneSecond);

  @override
  Future<void> signOut() => Future.delayed(oneSecond);

  @override
  String? get userId => 'foobar';
}
