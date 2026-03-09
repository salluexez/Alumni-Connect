import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream of current user (null when signed out)
  Stream<UserEntity?> get authStateChanges;

  /// Get currently signed-in user
  Future<UserEntity?> getCurrentUser();

  /// Sign in with email and password
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  });

  /// Create account with email and password
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
}
