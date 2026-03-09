import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> loginWithEmail({required String email, required String password});
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchUserFromFirestore(user.uid);
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _fetchUserFromFirestore(user.uid);
  }

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _fetchUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e));
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(name);

      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        photoUrl: null,
        role: role,
        skills: const [],
        isAvailableForMentoring: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      // Check if user already exists in Firestore
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // New Google user — create with default student role
      final userModel = UserModel(
        uid: uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName ?? 'User',
        photoUrl: userCredential.user!.photoURL,
        role: UserRole.student,
        skills: const [],
        isAvailableForMentoring: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Google sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e));
    }
  }

  Future<UserModel> _fetchUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw const NotFoundException(message: 'User profile not found');
    }
    return UserModel.fromFirestore(doc);
  }

  String _mapFirebaseError(FirebaseAuthException e) => switch (e.code) {
        'user-not-found' => 'No account found with this email',
        'wrong-password' => 'Incorrect password',
        'invalid-credential' => 'Invalid email or password',
        'email-already-in-use' => 'An account already exists with this email',
        'weak-password' => 'Password is too weak (min 6 characters)',
        'invalid-email' => 'Invalid email address',
        'user-disabled' => 'This account has been disabled',
        'too-many-requests' => 'Too many attempts. Please try again later',
        'network-request-failed' => 'Network error. Check your connection',
        _ => e.message ?? 'Authentication failed',
      };
}
