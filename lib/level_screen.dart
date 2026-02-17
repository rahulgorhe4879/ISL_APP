import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'level_screen.dart'; // This is the video-only screen
import 'hidden_object_game_screen.dart'; // This is the new game screen

// --- Define our App's Colors (Based on your image) ---
const Color kPrimaryColor = Color(0xFFF58634); // The new bright orange
const Color kPrimaryText = Color(0xFF3A3F51); // Dark blue/grey for header
const Color kSecondaryText = Color(0xFF7B7F8C); // Medium grey for subtitles
const Color kLockedColor = Color(0xFFF0F0F0); // Light grey for locked buttons
const Color kLockedText = Color(0xFFB8BCCB); // Medium grey for locked text
const Color kBackgroundColor = Color(0xFFFCFCFA); // The warm off-white background

// 1. The main entry point for the app
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LevelProgress(),
      child: const ISLApp(),
    ),
  );
}

// 2. The state management class (no change)
class LevelProgress extends ChangeNotifier {
  int _unlockedLevel = 1;
  int get unlockedLevel => _unlockedLevel;

  void completeLevel(int level) {
    if (level == _unlockedLevel) {
      _unlockedLevel++;
      notifyListeners();
    }
  }
}

// 3. The root widget of your application
class ISLApp extends StatelessWidget {
  const ISLApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISL App',
      theme: ThemeData(
        // --- NEW: Updated Theme ---
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        fontFamily: 'Roboto', // (Make sure to add this font to pubspec.yaml if you want)

        // We are not using a default AppBar in the new design
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor, // Match background
          elevation: 0,
        ),

        // New Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
      ),
      home: const LevelSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 4. The main screen with Level buttons
class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  final int totalLevels = 3;

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProgress>(
      builder: (context, levelProgress, child) {
        return Scaffold(
          // No AppBar, we build the header into the body
          body: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // --- NEW: Header from image ---
                  const _AppHeader(),
                  const SizedBox(height: 32),

                  // --- NEW: List of buttons ---
                  Expanded(
                    child: ListView.builder(
                      itemCount: totalLevels,
                      itemBuilder: (context, index) {
                        int levelNumber = index + 1;
                        bool isLocked = levelNumber > levelProgress.unlockedLevel;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: LevelButton(
                            levelNumber: levelNumber,
                            isLocked: isLocked,
                            onPressed: () {
                              Widget screenToOpen;
                              switch (levelNumber) {
                                case 1:
                                  screenToOpen = LevelScreen(level: levelNumber);
                                  break;
                                case 2:
                                  screenToOpen = HiddenObjectGameScreen(
                                      level: levelNumber);
                                  break;
                                default:
                                  screenToOpen = LevelScreen(level: levelNumber);
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => screenToOpen,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // --- NEW: Footer text ---
                  const SizedBox(height: 20),
                  const Text(
                    'Complete each level to unlock the next',
                    style: TextStyle(
                      color: kSecondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- NEW: Header Widget ---
class _AppHeader extends StatelessWidget {
  const _AppHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The book icon
            Icon(
              Icons.menu_book, // Using a standard icon
              color: kPrimaryText,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'ISL App',
              style: TextStyle(
                color: kPrimaryText,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Learn Indian Sign Language step by step',
          style: TextStyle(
            color: kSecondaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// 5. A custom widget for the Level Button
class LevelButton extends StatelessWidget {
  final int levelNumber;
  final bool isLocked;
  final VoidCallback onPressed;

  const LevelButton({
    Key? key,
    required this.levelNumber,
    required this.isLocked,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- NEW: Completely restyled button to match image ---
    Color buttonColor = isLocked ? kLockedColor : kPrimaryColor;
    Color iconColor = isLocked ? kLockedText : Colors.white;
    Color levelTextColor = isLocked ? kLockedText : Colors.white;
    Color subtitleTextColor =
    isLocked ? kLockedText : Colors.white.withOpacity(0.8);
    IconData icon = isLocked ? Icons.lock_outline : Icons.play_arrow; // Changed lock icon
    String subtitle = isLocked ? 'Locked' : 'Start Learning';

    return InkWell(
      onTap: isLocked ? null : onPressed, // Disable tap if locked
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isLocked
                ? []
                : [
              // Add shadow only if unlocked
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ]),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              'Level $levelNumber',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: levelTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: subtitleTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
