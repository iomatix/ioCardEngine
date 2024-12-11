import 'package:card_engine/services/user_data_manager.dart';
import 'package:card_engine/card_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'services/service_manager.dart';
import 'views/generate_cards_view.dart';
import 'views/main_menu_view.dart';
import 'views/playground_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Services
  ServiceManager().register<UserDataManager>(UserDataManager());

  // Setup Services
  final UserDataManager userDataManager =
      ServiceManager().get<UserDataManager>();
  await userDataManager.setupUserData();

  // Initialize CardEngine
  CardEngine.initialize(userDataManagerService: ServiceManager().get<UserDataManager>());
  //final CardEngine engineInstance = CardEngine.instance; 

  runApp(
    ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Card Engine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenuView(),
        '/playground': (context) => PlaygroundView(),
        //'/manage-cards': (context) => ManageCardsView(),
        //'/manage-decks': (context) => ManageDecksView(),
        '/generate-cards': (context) => GenerateCardsView(),
      },
    );
  }
}