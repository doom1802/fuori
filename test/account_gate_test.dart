import 'package:fuori/app/avatar_sprite.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuori/app/account_gate.dart';
import 'package:fuori/features/account/account_repository.dart';
import 'package:fuori/features/account/avatar_look.dart';

class _FakeAuth implements AuthRepository {
  final _events = StreamController<AccountAuthEvent>.broadcast();
  String? userId;
  int registrations = 0;

  @override
  String? get currentUserId => userId;

  @override
  Stream<AccountAuthEvent> get changes => _events.stream;

  void enter() {
    userId = 'account-1';
    _events.add(AccountAuthEvent.sessionChanged);
  }

  @override
  Future<bool> registerWithEmail(String email, String password) async {
    registrations++;
    return true;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async => enter();

  @override
  Future<void> signInWithGoogle() async => enter();

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> signOut() async {
    userId = null;
    _events.add(AccountAuthEvent.signedOut);
  }

  Future<void> dispose() => _events.close();
}

class _FakeAdultDeclarations implements AdultDeclarationRepository {
  bool declared = false;

  @override
  Future<bool> hasDeclared(String userId) async => declared;

  @override
  Future<void> declare(String userId) async {
    declared = true;
  }
}

class _FakeProfiles implements ProfileRepository {
  AccountProfile? profile;

  @override
  Future<AvatarLook> saveAvatar(String userId, AvatarLook look) async => look;

  @override
  Future<AccountProfile?> getMine(String userId) async => profile;

  @override
  Future<AccountProfile> saveName(String userId, String displayName) async =>
      profile = AccountProfile(id: userId, displayName: displayName);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await AvatarSpriteAssets.preload();
  });
  for (final width in [320.0, 420.0]) {
    testWidgets('la registrazione richiede la spunta 18+ a $width px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = _FakeAuth();
      addTearDown(auth.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: AccountGate(
            dependencies: AccountDependencies(
              auth: auth,
              adultDeclarations: _FakeAdultDeclarations(),
              profiles: _FakeProfiles(),
            ),
            homeBuilder: (profile, openSettings) => Text(profile.displayName),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Non hai un account? Registrati'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('account-email')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('account-password')),
        'password-sicura',
      );
      await tester.tap(find.text('Crea account'));
      await tester.pumpAndSettle();
      expect(auth.registrations, 0);
      expect(find.text('Conferma di avere almeno 18 anni.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('account-adult-checkbox')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crea account'));
      await tester.pumpAndSettle();
      expect(auth.registrations, 1);
      expect(find.textContaining('Controlla la tua email'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('senza dichiarazione e profilo la home resta chiusa', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 760);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = _FakeAuth()..userId = 'account-1';
    addTearDown(auth.dispose);
    final adults = _FakeAdultDeclarations();
    final profiles = _FakeProfiles();

    await tester.pumpWidget(
      MaterialApp(
        home: AccountGate(
          dependencies: AccountDependencies(
            auth: auth,
            adultDeclarations: adults,
            profiles: profiles,
          ),
          homeBuilder: (profile, openSettings) => Text(
            'Home di ${profile.displayName}',
            key: const Key('account-home'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adult-gate-checkbox')), findsOneWidget);
    expect(find.byKey(const Key('account-home')), findsNothing);
    await tester.tap(find.byKey(const Key('adult-gate-checkbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();
    expect(adults.declared, isTrue);
    expect(find.byKey(const Key('profile-name')), findsOneWidget);
    expect(find.byKey(const Key('account-home')), findsNothing);
    await tester.enterText(find.byKey(const Key('profile-name')), 'Domi');
    await tester.tap(find.text('Salva il profilo'));
    await tester.pumpAndSettle();
    expect(find.text('Home di Domi'), findsOneWidget);
    await auth.signOut();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-email')), findsOneWidget);
    expect(find.byKey(const Key('account-home')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
