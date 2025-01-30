
import 'package:kavruk/user/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn(String email, String password);
  Future<AuthUser> createUser(String email, String password);
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> resetPassword(String email);
}
