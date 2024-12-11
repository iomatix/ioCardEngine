import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/card_game_widget.dart';

class PlaygroundView extends ConsumerStatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}


class _GameScreenState extends ConsumerState<PlaygroundView> {
  // Drawer visibility and size state
  bool _isDrawerVisible = false;

  final double _collapsedWidth = 60;  // Drawer width when collapsed
  final double _expandedWidth = 200;  // Drawer width when expanded

  double _drawerWidth = 60;  // Drawer initial width

  // Decoupled game widget
  final CardGameWidget gameWidget = CardGameWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Screen"),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate to main menu
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Reset the game
              //ref.read(gameProvider.notifier).resetGame();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // GameWidget as the background (main game view)
          gameWidget,
          // Drawer with positioning logic
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                // Expand the drawer when user drags
                if (details.primaryDelta! < 0) {
                  setState(() {
                    _isDrawerVisible = true;
                    _drawerWidth = _expandedWidth;
                  });
                }
              },
              onTap: () {
                setState(() {
                  // Toggle visibility on tap
                  _isDrawerVisible = !_isDrawerVisible;
                  _drawerWidth = _isDrawerVisible ? _expandedWidth : _collapsedWidth;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 256),
                width: _drawerWidth,
                color: Colors.blueGrey,
                child: Column(
                  children: [ if (_isDrawerVisible) ...[ 
                    ListTile(
                      title: Text("Pause Game"),
                      onTap: () {
                        // Handle pause game functionality
                      },
                    ),
                    ListTile(
                      title: Text("Settings"),
                      onTap: () {
                        // Open settings or options for real-time controls
                      },
                    ),

                  ] else Center(child: Icon(Icons.arrow_back))],
                ),
              ),
            ),
          ),
        ],
      ),
      // Drawer for extra controls (This is the main drawer, already integrated into the body)
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Option 1"),
              onTap: () {
                // Add game control options here
              },
            ),
            ListTile(
              title: Text("Option 2"),
              onTap: () {
                // Add more options if needed
              },
            ),
          ],
        ),
      ),
    );
  }
}