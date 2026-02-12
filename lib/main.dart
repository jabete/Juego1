import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/game_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const FlagBattleApp());
}

class FlagBattleApp extends StatelessWidget {
  const FlagBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banderas Battle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(gameService: GameService()),
    );
  }
}
