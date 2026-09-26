import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/account/account_repository.dart';
import 'fuori_theme.dart';
import 'widgets.dart';

class AccountGate extends StatefulWidget {
  const AccountGate({
    super.key,
    required this.dependencies,
    required this.homeBuilder,
  });

  final AccountDependencies dependencies;
  final Widget Function(
    AccountProfile profile,
    VoidCallback openAccountSettings,
  )
  homeBuilder;

  @override
  State<AccountGate> createState() => _AccountGateState();
}

class _AccountSnapshot {
  const _AccountSnapshot({
    this.userId,
    this.adultDeclared = false,
    this.profile,
  });

  final String? userId;
  final bool adultDeclared;
  final AccountProfile? profile;
}

class _AccountGateState extends State<AccountGate> {
  late Future<_AccountSnapshot> _snapshot;
  late StreamSubscription<AccountAuthEvent> _subscription;
  bool _passwordRecovery = false;
  bool _editingProfile = false;

  @override
  void initState() {
    super.initState();
    _snapshot = _load();
    _subscription = widget.dependencies.auth.changes.listen((event) {
      if (!mounted) return;
      setState(() {
        if (event == AccountAuthEvent.passwordRecovery) {
          _passwordRecovery = true;
        } else if (event == AccountAuthEvent.signedOut) {
          _passwordRecovery = false;
          _editingProfile = false;
        }
        _snapshot = _load();
      });
    });
  }

  Future<_AccountSnapshot> _load() async {
    final userId = widget.dependencies.auth.currentUserId;
    if (userId == null) return const _AccountSnapshot();
    final adult = await widget.dependencies.adultDeclarations.hasDeclared(
      userId,
    );
    if (!adult) return _AccountSnapshot(userId: userId);
    final profile = await widget.dependencies.profiles.getMine(userId);
    return _AccountSnapshot(
      userId: userId,
      adultDeclared: true,
      profile: profile,
    );
  }

  void _reload() {
    setState(() {
      _snapshot = _load();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_AccountSnapshot>(
    future: _snapshot,
    builder: (context, result) {
      if (result.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (result.hasError) {
        return _AccountPage(
          eyebrow: 'Account',
          title: 'Riproviamo.',
          description: 'Non riusciamo a caricare il tuo profilo.',
          children: [FuoriButton(label: 'Riprova', onPressed: _reload)],
        );
      }
      final account = result.requireData;
      if (account.userId == null) {
        return _AuthScreen(auth: widget.dependencies.auth);
      }
      if (_passwordRecovery) {
        return _PasswordUpdateScreen(
          auth: widget.dependencies.auth,
          onDone: () {
            setState(() => _passwordRecovery = false);
            _reload();
          },
        );
      }
      if (!account.adultDeclared) {
        return _AdultDeclarationScreen(
          onDeclare: () async {
            await widget.dependencies.adultDeclarations.declare(
              account.userId!,
            );
            _reload();
          },
          onSignOut: widget.dependencies.auth.signOut,
        );
      }
      if (account.profile == null || _editingProfile) {
        return _ProfileEditorScreen(
          key: ValueKey(account.profile?.id ?? account.userId),
          initialName: account.profile?.displayName,
          onSave: (name) async {
            await widget.dependencies.profiles.saveName(account.userId!, name);
            _editingProfile = false;
            _reload();
          },
          onCancel: account.profile == null
              ? null
              : () => setState(() => _editingProfile = false),
          onSignOut: widget.dependencies.auth.signOut,
        );
      }
      return widget.homeBuilder(
        account.profile!,
        () => setState(() => _editingProfile = true),
      );
    },
  );
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'fuori'),
                    TextSpan(
                      text: '.',
                      style: TextStyle(color: context.accent),
                    ),
                  ],
                ),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 36),
              Eyebrow(eyebrow),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

enum _AuthMode { signIn, register, reset }

class _AuthScreen extends StatefulWidget {
  const _AuthScreen({required this.auth});

  final AuthRepository auth;

  @override
  State<_AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<_AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  bool _adultChecked = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _switch(_AuthMode mode) => setState(() {
    _mode = mode;
    _message = null;
    _adultChecked = false;
  });

  Future<void> _submit() async {
    if (_busy) return;
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _message = 'Inserisci un indirizzo email valido.');
      return;
    }
    if (_mode != _AuthMode.reset && _password.text.length < 8) {
      setState(() => _message = 'La password deve avere almeno 8 caratteri.');
      return;
    }
    if (_mode == _AuthMode.register && !_adultChecked) {
      setState(() => _message = 'Conferma di avere almeno 18 anni.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      switch (_mode) {
        case _AuthMode.signIn:
          await widget.auth.signInWithEmail(email, _password.text);
        case _AuthMode.register:
          final confirmEmail = await widget.auth.registerWithEmail(
            email,
            _password.text,
          );
          if (mounted && confirmEmail) {
            setState(
              () => _message = 'Controlla la tua email per confermare l’account. Poi torna qui ed entra.',
            );
          }
        case _AuthMode.reset:
          await widget.auth.sendPasswordReset(email);
          if (mounted) {
            setState(
              () => _message = 'Se l’indirizzo è registrato, riceverai un link per cambiare password.',
            );
          }
      }
    } catch (error) {
      if (mounted) setState(() => _message = _accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    if (_busy) return;
    if (_mode == _AuthMode.register && !_adultChecked) {
      setState(() => _message = 'Conferma di avere almeno 18 anni.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.auth.signInWithGoogle();
    } catch (error) {
      if (mounted) setState(() => _message = _accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AccountPage(
    eyebrow: _mode == _AuthMode.register ? 'Il tuo account' : 'Bentornato',
    title: switch (_mode) {
      _AuthMode.signIn => 'Ci vediamo fuori.',
      _AuthMode.register => 'Iniziamo da te.',
      _AuthMode.reset => 'Ritrova l’accesso.',
    },
    description: switch (_mode) {
      _AuthMode.signIn => 'Entra con email e password o con Google.',
      _AuthMode.register => 'Fuori è riservato a persone maggiorenni.',
      _AuthMode.reset =>
        'Ti mandiamo un link per scegliere una nuova password.',
    },
    children: [
      TextField(
        key: const Key('account-email'),
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
      if (_mode != _AuthMode.reset) ...[
        const SizedBox(height: 13),
        TextField(
          key: const Key('account-password'),
          controller: _password,
          obscureText: true,
          autofillHints: [
            _mode == _AuthMode.register
                ? AutofillHints.newPassword
                : AutofillHints.password,
          ],
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
      ],
      if (_mode == _AuthMode.register) ...[
        const SizedBox(height: 12),
        CheckboxListTile(
          key: const Key('account-adult-checkbox'),
          value: _adultChecked,
          onChanged: _busy
              ? null
              : (value) => setState(() => _adultChecked = value ?? false),
          title: const Text('Confermo di avere almeno 18 anni'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
      if (_message != null) ...[
        const SizedBox(height: 12),
        Text(
          _message!,
          key: const Key('account-message'),
          style: TextStyle(color: context.accent),
        ),
      ],
      const SizedBox(height: 20),
      FuoriButton(
        label: switch (_mode) {
          _AuthMode.signIn => 'Entra',
          _AuthMode.register => 'Crea account',
          _AuthMode.reset => 'Invia il link',
        },
        onPressed: _busy ? null : _submit,
      ),
      if (_mode != _AuthMode.reset) ...[
        const SizedBox(height: 10),
        FuoriButton(
          label: 'Continua con Google',
          icon: Icons.login_rounded,
          secondary: true,
          onPressed: _busy ? null : _google,
        ),
      ],
      const SizedBox(height: 16),
      if (_mode == _AuthMode.signIn) ...[
        TextButton(
          onPressed: () => _switch(_AuthMode.register),
          child: const Text('Non hai un account? Registrati'),
        ),
        TextButton(
          onPressed: () => _switch(_AuthMode.reset),
          child: const Text('Hai dimenticato la password?'),
        ),
      ] else
        TextButton(
          onPressed: () => _switch(_AuthMode.signIn),
          child: const Text('Torna all’accesso'),
        ),
    ],
  );
}

class _AdultDeclarationScreen extends StatefulWidget {
  const _AdultDeclarationScreen({
    required this.onDeclare,
    required this.onSignOut,
  });

  final Future<void> Function() onDeclare;
  final Future<void> Function() onSignOut;

  @override
  State<_AdultDeclarationScreen> createState() =>
      _AdultDeclarationScreenState();
}

class _AdultDeclarationScreenState extends State<_AdultDeclarationScreen> {
  bool _checked = false;
  bool _busy = false;
  String? _message;

  Future<void> _declare() async {
    if (!_checked || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.onDeclare();
    } catch (error) {
      if (mounted) setState(() => _message = _accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AccountPage(
    eyebrow: 'Prima di entrare',
    title: 'Fuori è 18+.',
    description: 'Per usare l’app devi dichiarare di avere almeno 18 anni. Non chiediamo la tua data di nascita.',
    children: [
      CheckboxListTile(
        key: const Key('adult-gate-checkbox'),
        value: _checked,
        onChanged: _busy
            ? null
            : (value) => setState(() => _checked = value ?? false),
        title: const Text('Confermo di avere almeno 18 anni'),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
      if (_message != null)
        Text(_message!, style: TextStyle(color: context.accent)),
      const SizedBox(height: 18),
      FuoriButton(
        label: 'Continua',
        onPressed: _checked && !_busy ? _declare : null,
      ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: _busy ? null : widget.onSignOut,
        child: const Text('Esci dall’account'),
      ),
    ],
  );
}

class _ProfileEditorScreen extends StatefulWidget {
  const _ProfileEditorScreen({
    super.key,
    required this.initialName,
    required this.onSave,
    required this.onCancel,
    required this.onSignOut,
  });

  final String? initialName;
  final Future<void> Function(String) onSave;
  final VoidCallback? onCancel;
  final Future<void> Function() onSignOut;

  @override
  State<_ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<_ProfileEditorScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final name = _name.text.trim();
    if (name.length < 2 || name.length > 30) {
      setState(() => _message = 'Il nome deve avere da 2 a 30 caratteri.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.onSave(name);
    } catch (error) {
      if (mounted) setState(() => _message = _accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AccountPage(
    eyebrow: 'Il tuo profilo',
    title: widget.initialName == null ? 'Come ti chiami?' : 'Il tuo nome.',
    description: 'Questo nome identifica il tuo profilo. Il personaggio definitivo arriverà nella prossima fase.',
    children: [
      TextField(
        key: const Key('profile-name'),
        controller: _name,
        maxLength: 30,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Nome',
          border: OutlineInputBorder(),
        ),
      ),
      if (_message != null)
        Text(_message!, style: TextStyle(color: context.accent)),
      const SizedBox(height: 14),
      FuoriButton(label: 'Salva il profilo', onPressed: _busy ? null : _save),
      if (widget.onCancel != null)
        TextButton(onPressed: widget.onCancel, child: const Text('Annulla')),
      TextButton(
        onPressed: _busy ? null : widget.onSignOut,
        child: const Text('Esci dall’account'),
      ),
    ],
  );
}

class _PasswordUpdateScreen extends StatefulWidget {
  const _PasswordUpdateScreen({required this.auth, required this.onDone});

  final AuthRepository auth;
  final VoidCallback onDone;

  @override
  State<_PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<_PasswordUpdateScreen> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_password.text.length < 8) {
      setState(() => _message = 'La password deve avere almeno 8 caratteri.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.auth.updatePassword(_password.text);
      widget.onDone();
    } catch (error) {
      if (mounted) setState(() => _message = _accountError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AccountPage(
    eyebrow: 'Recupero accesso',
    title: 'Nuova password.',
    description: 'Scegli la password da usare per entrare con la tua email.',
    children: [
      TextField(
        key: const Key('new-password'),
        controller: _password,
        obscureText: true,
        autofillHints: const [AutofillHints.newPassword],
        decoration: const InputDecoration(
          labelText: 'Nuova password',
          border: OutlineInputBorder(),
        ),
      ),
      if (_message != null)
        Text(_message!, style: TextStyle(color: context.accent)),
      const SizedBox(height: 18),
      FuoriButton(label: 'Aggiorna password', onPressed: _busy ? null : _save),
    ],
  );
}

String _accountError(Object error) {
  if (error is FormatException) return error.message;
  if (error is AuthException) {
    return switch (error.code) {
      'invalid_credentials' => 'Email o password non corretti.',
      'email_not_confirmed' => 'Conferma l’email prima di entrare.',
      'weak_password' => 'Scegli una password più sicura.',
      'over_email_send_rate_limit' =>
        'Hai richiesto troppe email. Riprova più tardi.',
      _ => 'Operazione non riuscita. Controlla i dati e riprova.',
    };
  }
  return 'Operazione non riuscita. Riprova tra poco.';
}
