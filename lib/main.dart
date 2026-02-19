import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'level_screen.dart';
import 'hidden_object_game_screen.dart';

// ---------------- DATA MODEL ----------------

class LessonPageData {
  final String videoAsset;
  final String imageAsset;
  final String objectName;

  LessonPageData({
    required this.videoAsset,
    required this.imageAsset,
    required this.objectName,
  });
}

// ---------------- LEVEL DATA ----------------

final Map<int, List<LessonPageData>> levelData = {
  1: [
    LessonPageData(videoAsset: 'assets/videos/bicycle.MOV', imageAsset: 'assets/images/bicycle.png', objectName: 'Bicycle'),
    LessonPageData(videoAsset: 'assets/videos/ball.MOV', imageAsset: 'assets/images/ball.png', objectName: 'Ball'),
    LessonPageData(videoAsset: 'assets/videos/car.MOV', imageAsset: 'assets/images/car.png', objectName: 'Car'),
    LessonPageData(videoAsset: 'assets/videos/boat.MOV', imageAsset: 'assets/images/boat.png', objectName: 'Boat'),
    LessonPageData(videoAsset: 'assets/videos/book.MOV', imageAsset: 'assets/images/book.png', objectName: 'Book'),
    LessonPageData(videoAsset: 'assets/videos/bag.MOV', imageAsset: 'assets/images/bag.png', objectName: 'Bag'),
  ],
};

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LevelProgress(),
      child: const ISLApp(),
    ),
  );
}

// ---------------- GLOBAL STATE ----------------

class LevelProgress extends ChangeNotifier {
  int _unlockedLevel = 1;
  int _hearts = 0;
  bool _isDarkMode = false;
  final Map<int, int> _levelCompletionCount = {};

  int get unlockedLevel => _unlockedLevel;
  int get hearts => _hearts;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void addHeart() {
    _hearts++;
    notifyListeners();
  }

  void removeHeart() {
    if (_hearts > 0) {
      _hearts--;
      notifyListeners();
    }
  }

  void completeLevel(int level) {
    if (level == _unlockedLevel) {
      _unlockedLevel++;
      notifyListeners();
    }
  }

  void lockLevel(int level) {
    if (level <= _unlockedLevel && level > 1) {
      _unlockedLevel = level - 1;
      notifyListeners();
    }
  }

  void incrementLevelProgress(int level) {
    _levelCompletionCount[level] =
        (_levelCompletionCount[level] ?? 0) + 1;
    notifyListeners();
  }

  double getProgress(int level, int totalItems) {
    final completed = _levelCompletionCount[level] ?? 0;
    if (totalItems == 0) return 0;
    return (completed / totalItems).clamp(0.0, 1.0);
  }
}

// ---------------- APP ----------------

class ISLApp extends StatelessWidget {
  const ISLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProgress>(
      builder: (context, progress, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode:
          progress.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const LevelSelectionScreen(),
        );
      },
    );
  }
}

// ---------------- LEVEL SCREEN ----------------

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProgress>(
      builder: (context, progress, _) {
        final isDark = progress.isDarkMode;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                colors: [
                  Color(0xFF1E293B), // lighter navy
                  Color(0xFF334155), // slate blue
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
                  : const LinearGradient(
                colors: [
                  Color(0xFFFFF3E8),
                  Color(0xFFFFE0C4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [

                  // HEADER
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black45 : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // Hearts
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              "${progress.hearts}",
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),

                        // BIGGER TITLE
                        Text(
                          "ISL App",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.yellow : Colors.black,
                          ),
                          onPressed: () => progress.toggleTheme(),
                        )
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildLevelCard(context, 1, progress, isDark),
                          const SizedBox(height: 20),
                          _buildLevelCard(context, 2, progress, isDark),
                          const SizedBox(height: 20),
                          _buildLevelCard(context, 3, progress, isDark),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(
      BuildContext context,
      int level,
      LevelProgress progress,
      bool isDark) {

    bool isLocked = level > progress.unlockedLevel;

    int totalItems =
    level == 1 ? levelData[1]?.length ?? 1 : 5;

    double progressValue =
    progress.getProgress(level, totalItems);

    return Expanded(
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () {
          Widget screen = (level == 2)
              ? HiddenObjectGameScreen(level: level)
              : LevelScreen(level: level);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isLocked
                ? LinearGradient(
              colors: isDark
                  ? const [Color(0xFF3F3F46), Color(0xFF2D2D2D)]
                  : const [Color(0xFF555555), Color(0xFF444444)],
            )
                : isDark
                ? const LinearGradient(
              colors: [
                Color(0xFF4338CA), // softer purple
                Color(0xFF1E40AF), // softer blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : const LinearGradient(
              colors: [
                Color(0xFFF9A14A),
                Color(0xFFF58634),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLocked ? Icons.lock : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  "Level $level",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}