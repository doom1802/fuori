import 'package:flutter/material.dart';

import 'app/fuori_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FuoriApp(dependencies: FuoriDependencies.demo()));
}
