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
    LessonPageData(
        videoAsset: 'assets/videos/bicycle.MOV',
        imageAsset: 'assets/images/bicycle.png',
        objectName: 'Bicycle'),
    LessonPageData(
        videoAsset: 'assets/videos/ball.MOV',
        imageAsset: 'assets/images/ball.png',
        objectName: 'Ball'),
    LessonPageData(
        videoAsset: 'assets/videos/car.MOV',
        imageAsset: 'assets/images/car.png',
        objectName: 'Car'),
    LessonPageData(
        videoAsset: 'assets/videos/boat.MOV',
        imageAsset: 'assets/images/boat.png',
        objectName: 'Boat'),
    LessonPageData(
        videoAsset: 'assets/videos/book.MOV',
        imageAsset: 'assets/images/book.png',
        objectName: 'Book'),
    LessonPageData(
        videoAsset: 'assets/videos/bag.MOV',
        imageAsset: 'assets/images/bag.png',
        objectName: 'Bag'),
    LessonPageData(
        videoAsset: 'assets/videos/clock.MOV',
        imageAsset: 'assets/images/clock.png',
        objectName: 'Clock'),
    LessonPageData(
        videoAsset: 'assets/videos/dog.MOV',
        imageAsset: 'assets/images/dog.png',
        objectName: 'Dog'),
    LessonPageData(
        videoAsset: 'assets/videos/fish.MOV',
        imageAsset: 'assets/images/fish.png',
        objectName: 'Fish'),
    LessonPageData(
        videoAsset: 'assets/videos/table.MOV',
        imageAsset: 'assets/images/table.png',
        objectName: 'Table'),
  ],
};

// ---------------- COLORS ----------------

const Color kPrimaryColor = Color(0xFFF58634);
const Color kPrimaryText = Color(0xFF3A3F51);
const Color kBackgroundColor = Color(0xFFFCFCFA);

// ---------------- MAIN ----------------

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LevelProgress(),
      child: const ISLApp(),
    ),
  );
}

// ---------------- LEVEL PROGRESS (GLOBAL STATE) ----------------

class LevelProgress extends ChangeNotifier {
  int _unlockedLevel = 1;
  int _hearts = 0;

  int get unlockedLevel => _unlockedLevel;
  int get hearts => _hearts;

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
}

// ---------------- APP ----------------

class ISLApp extends StatelessWidget {
  const ISLApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LevelSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------------- LEVEL SELECTION SCREEN ----------------

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProgress>(
      builder: (context, levelProgress, child) {
        return Scaffold(
          backgroundColor: kBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [

                // MAIN CONTENT
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const _AppHeader(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildLevelItem(
                                context,
                                1,
                                levelProgress),
                            const SizedBox(height: 12),
                            _buildLevelItem(
                                context,
                                2,
                                levelProgress),
                            const SizedBox(height: 12),
                            _buildLevelItem(
                                context,
                                3,
                                levelProgress),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ❤️ GLOBAL HEART DISPLAY
                Positioned(
                  top: 15,
                  right: 20,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${levelProgress.hearts}',
                        style:
                        const TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelItem(
      BuildContext context,
      int level,
      LevelProgress progress) {
    bool isLocked =
        level > progress.unlockedLevel;

    return Expanded(
      child: LevelButton(
        levelNumber: level,
        isLocked: isLocked,
        onPressed: () {
          Widget screen =
          (level == 2)
              ? HiddenObjectGameScreen(
              level: level)
              : LevelScreen(
              level: level);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                screen),
          );
        },
      ),
    );
  }
}

// ---------------- HEADER ----------------

class _AppHeader extends StatelessWidget {
  const _AppHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book,
                color: kPrimaryText,
                size: 28),
            SizedBox(width: 8),
            Text(
              'ISL App',
              style: TextStyle(
                color: kPrimaryText,
                fontSize: 28,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          'Learn Indian Sign Language step by step',
          style: TextStyle(
              color: Color(0xFF7B7F8C),
              fontSize: 14),
        ),
      ],
    );
  }
}

// ---------------- LEVEL BUTTON ----------------

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
    return InkWell(
      onTap: isLocked ? null : onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLocked
              ? const Color(0xFFF0F0F0)
              : kPrimaryColor,
          borderRadius:
          BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isLocked
                  ? Icons.lock_outline
                  : Icons.play_arrow,
              color: isLocked
                  ? const Color(
                  0xFFB8BCCB)
                  : Colors.white,
              size: 30,
            ),
            Text(
              'Level $levelNumber',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
                color: isLocked
                    ? const Color(
                    0xFFB8BCCB)
                    : Colors.white,
              ),
            ),
            Text(
              isLocked
                  ? 'Locked'
                  : 'Start Learning',
              style: TextStyle(
                fontSize: 16,
                color: isLocked
                    ? const Color(
                    0xFFB8BCCB)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}