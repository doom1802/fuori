import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/fuori_app.dart';
import 'data/supabase/supabase_account_repositories.dart';
import 'features/account/account_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (url.isEmpty && publishableKey.isEmpty) {
    runApp(FuoriApp(dependencies: FuoriDependencies.demo()));
    return;
  }
  if (url.isEmpty || publishableKey.isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Configurazione Supabase incompleta.')),
        ),
      ),
    );
    return;
  }

  await Supabase.initialize(url: url, publishableKey: publishableKey);
  final client = Supabase.instance.client;
  runApp(
    FuoriApp(
      dependencies: FuoriDependencies.demo(),
      accountDependencies: AccountDependencies(
        auth: SupabaseAuthRepository(client),
        adultDeclarations: SupabaseAdultDeclarationRepository(client),
        profiles: SupabaseProfileRepository(client),
      ),
    ),
  );
}
