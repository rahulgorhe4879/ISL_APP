import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // To access LevelProgress and colors

// This class holds the data for a single object to be found
class HiddenObject {
  final String name; // The name of the object (must match target list)
  final String assetPath; // Path to the object's image (e.g., 'assets/images/book.png')
  final double top; // Position from the top
  final double left; // Position from the left
  final double width; // Size of the tappable area
  final double height;

  HiddenObject({
    required this.name,
    required this.assetPath,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
}

// List of all objects to find in this level
final List<HiddenObject> level2Objects = [
  // !! REPLACE with your assets and positions
  HiddenObject(
    name: 'Book',
    assetPath: 'assets/images/book.png', // !! REPLACE
    top: 150.0,
    left: 220.0,
    width: 50.0,
    height: 50.0,
  ),
  HiddenObject(
    name: 'Fan',
    assetPath: 'assets/images/fan.png', // !! REPLACE
    top: 300.0,
    left: 100.0,
    width: 60.0,
    height: 60.0,
  ),
  HiddenObject(
    name: 'Cat',
    assetPath: 'assets/images/cat.png', // !! REPLACE
    top: 450.0,
    left: 250.0,
    width: 70.0,
    height: 70.0,
  ),
  HiddenObject(
    name: 'Clock',
    assetPath: 'assets/images/clock.png', // !! REPLACE
    top: 80.0,
    left: 50.0,
    width: 40.0,
    height: 40.0,
  ),
];

// List of the target words for the user to find
final List<String> level2Targets = ['Book', 'Fan', 'Cat', 'Clock'];
// --- End Level 2 Config ---

class HiddenObjectGameScreen extends StatefulWidget {
  final int level;
  const HiddenObjectGameScreen({Key? key, required this.level})
      : super(key: key);

  @override
  _HiddenObjectGameScreenState createState() => _HiddenObjectGameScreenState();
}

class _HiddenObjectGameScreenState extends State<HiddenObjectGameScreen> {
  // A Set to keep track of which items we've found
  final Set<String> _foundObjects = {};
  bool _allFound = false;

  void _onObjectTapped(String objectName) {
    // Check if this is a target object and hasn't been found yet
    if (level2Targets.contains(objectName) &&
        !_foundObjects.contains(objectName)) {
      setState(() {
        _foundObjects.add(objectName);

        // Check if all objects have been found
        if (_foundObjects.length == level2Targets.length) {
          _allFound = true;
        }
      });

      // Show a confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You found the $objectName!'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _completeLevel() {
    Provider.of<LevelProgress>(context, listen: false)
        .completeLevel(widget.level);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level} - Find the Objects'),
        backgroundColor: kBackgroundColor, // Match new theme
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimaryText), // Match new theme
        titleTextStyle: TextStyle( // Match new theme
            color: kPrimaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
      ),
      // --- NEW: Use a Stack to overlay the HUD on the game ---
      body: Stack(
        children: [
          // --- 1. The Game Area ---
          InteractiveViewer(
            // Allows pinch-to-zoom
            maxScale: 4.0,
            child: Stack(
              children: [
                // --- The Background Image ---
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.jpg', // !! REPLACE
                    fit: BoxFit.cover,
                    // Error handling for missing image
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text('Error: Could not load background.jpg'),
                        ),
                      );
                    },
                  ),
                ),

                // --- The Tappable Objects ---
                ...level2Objects.map((obj) {
                  bool isFound = _foundObjects.contains(obj.name);
                  return Positioned(
                    top: obj.top,
                    left: obj.left,
                    width: obj.width,
                    height: obj.height,
                    child: GestureDetector(
                      onTap: () => _onObjectTapped(obj.name),
                      child: Container(
                        // --- NEW: More visible "found" indicator ---
                        decoration: isFound
                            ? BoxDecoration(
                            border: Border.all(
                                color: Colors.greenAccent, width: 4.0),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green.withOpacity(0.4))
                            : null,
                        child: Image.asset(
                          obj.assetPath,
                          fit: BoxFit.contain,
                          // Error handling for missing object images
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.red.withOpacity(0.3),
                              child: Center(
                                child: Text(obj.name,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // --- 2. The Target List (as an overlay) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // --- NEW: A semi-transparent "HUD" background ---
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Adjusted padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find these objects:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // NEW: White text
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 8.0,
                    children: level2Targets.map((target) {
                      bool isFound = _foundObjects.contains(target);
                      return Chip(
                        label: Text(
                          target,
                          style: TextStyle(
                            color: isFound ? Colors.white : Colors.black87,
                            decoration: isFound
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        // --- NEW: Better chip colors ---
                        backgroundColor: isFound
                            ? Colors.green.shade600
                            : Colors.grey.shade200,
                        avatar: isFound
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      );
                    }).toList(),
                  ),
                  // --- 3. The Complete Level Button ---
                  if (_allFound)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: _completeLevel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Level Complete!'),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

