import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/account/account_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<AccountAuthEvent> get changes => _client.auth.onAuthStateChange.map(
    (state) => switch (state.event) {
      AuthChangeEvent.signedOut => AccountAuthEvent.signedOut,
      AuthChangeEvent.passwordRecovery => AccountAuthEvent.passwordRecovery,
      _ => AccountAuthEvent.sessionChanged,
    },
  );

  String get _webRedirect => '${Uri.base.origin}/';

  @override
  Future<bool> registerWithEmail(String email, String password) async {
    final result = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: kIsWeb ? _webRedirect : null,
    );
    return result.session == null;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? _webRedirect : null,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: kIsWeb ? _webRedirect : null,
      );

  @override
  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

class SupabaseAdultDeclarationRepository implements AdultDeclarationRepository {
  SupabaseAdultDeclarationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<bool> hasDeclared(String userId) async {
    final row = await _client
        .from('adult_declarations')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    return row != null;
  }

  @override
  Future<void> declare(String userId) async {
    await _client.from('adult_declarations').insert({
      'user_id': userId,
      'confirmed_adult': true,
    });
  }
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AccountProfile?> getMine(String userId) async {
    final row = await _client
        .from('profiles')
        .select('id, display_name')
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return AccountProfile(
      id: row['id'] as String,
      displayName: row['display_name'] as String,
    );
  }

  @override
  Future<AccountProfile> saveName(String userId, String displayName) async {
    final name = displayName.trim();
    if (name.length < 2 || name.length > 30) {
      throw const FormatException('Il nome deve avere da 2 a 30 caratteri.');
    }
    final existing = await getMine(userId);
    if (existing == null) {
      await _client.from('profiles').insert({
        'id': userId,
        'display_name': name,
      });
    } else {
      await _client
          .from('profiles')
          .update({'display_name': name})
          .eq('id', userId);
    }
    return AccountProfile(id: userId, displayName: name);
  }
}
