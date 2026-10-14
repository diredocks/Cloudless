import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/caiyun_api.dart';
import 'screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(CloudlessApp(api: CaiyunApi()));
}

class CloudlessApp extends StatelessWidget {
  const CloudlessApp({super.key, required this.api});

  final CaiyunApi api;

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
      home: HomeShell(api: api),
    );
  }
}
