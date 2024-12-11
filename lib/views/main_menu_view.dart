import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/menu_button.dart';

class MainMenuView extends ConsumerWidget {
  const MainMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              label: 'Playground',
              onPressed: () => _navigateToPlayground(context),
            ),
            const SizedBox(height: 16),
            MenuButton(
              label: 'Manage Cards',
              onPressed: () => _navigateToManageCards(context),
            ),
            const SizedBox(height: 16),
            MenuButton(
              label: 'Manage Decks',
              onPressed: () => _navigateToManageDecks(context),
            ),
            const SizedBox(height: 16),
            MenuButton(
              label: 'Generate Cards from PDF',
              onPressed: () => _navigateToGenerateCards(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPlayground(BuildContext context) {
    Navigator.pushNamed(context, '/playground');
  }

  void _navigateToManageCards(BuildContext context) {
    Navigator.pushNamed(context, '/manage-cards');
  }

  void _navigateToManageDecks(BuildContext context) {
    Navigator.pushNamed(context, '/manage-decks');
  }

  void _navigateToGenerateCards(BuildContext context) {
    Navigator.pushNamed(context, '/generate-cards');
  }
}
