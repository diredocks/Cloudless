import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CloudlessApp());
}

class CloudlessApp extends StatelessWidget {
  const CloudlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cloudless',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        fontFamily: null,
      ),
      home: const HomeShell(),
    );
  }
}
