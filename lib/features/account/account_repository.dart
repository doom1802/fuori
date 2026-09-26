import 'avatar_look.dart';

enum AccountAuthEvent { sessionChanged, signedOut, passwordRecovery }

abstract interface class AuthRepository {
  String? get currentUserId;
  Stream<AccountAuthEvent> get changes;

  /// Returns true when email confirmation is required before sign-in.
  Future<bool> registerWithEmail(String email, String password);
  Future<void> signInWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signOut();
}

abstract interface class AdultDeclarationRepository {
  Future<bool> hasDeclared(String userId);
  Future<void> declare(String userId);
}

class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.displayName,
    this.avatarLook = const AvatarLook(),
  });

  final String id;
  final String displayName;
  final AvatarLook avatarLook;
}

abstract interface class ProfileRepository {
  Future<AccountProfile?> getMine(String userId);
  Future<AccountProfile> saveName(String userId, String displayName);
  Future<AvatarLook> saveAvatar(String userId, AvatarLook look);
}

class AccountDependencies {
  const AccountDependencies({
    required this.auth,
    required this.adultDeclarations,
    required this.profiles,
  });

  final AuthRepository auth;
  final AdultDeclarationRepository adultDeclarations;
  final ProfileRepository profiles;
}
