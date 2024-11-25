import 'package:card_engine/services/user_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'services/service_manager.dart';
import 'widgets/card_game_widget.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Services
  ServiceManager().register<UserDataManager>(UserDataManager());
  
  // Setup Services
  final UserDataManager userDataManager = ServiceManager().get<UserDataManager>();
  userDataManager.setupUserData();
    userDataManager.createDirectory(category: 'test', relativePath: 'newbabe');
    userDataManager.createDirectory(category: 'test', relativePath: 'testtest');
    userDataManager.deleteDirectory(category: 'test', relativePath: 'placeholder');
    userDataManager.createDirectory(category: 'test', relativePath: 'romek/dwazero');

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
      home: Scaffold(
        body: Center(
          child: CardGameWidget(),
        ),
      ),
    );
  }
}


