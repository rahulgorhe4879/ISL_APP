import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'level_screen.dart';
import 'hidden_object_game_screen.dart';

// --- DATA MODEL ---
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

// Global data: Level 1 has 10 words, Level 2 sequence is Ball -> Car -> Boat -> Book -> Bag
final Map<int, List<LessonPageData>> levelData = {
  1: [
    LessonPageData(videoAsset: 'assets/videos/bicycle.MOV', imageAsset: 'assets/images/bicycle.png', objectName: 'Bicycle'),
    LessonPageData(videoAsset: 'assets/videos/ball.MOV', imageAsset: 'assets/images/ball.png', objectName: 'Ball'),
    LessonPageData(videoAsset: 'assets/videos/car.MOV', imageAsset: 'assets/images/car.png', objectName: 'Car'),
    LessonPageData(videoAsset: 'assets/videos/boat.MOV', imageAsset: 'assets/images/boat.png', objectName: 'Boat'),
    LessonPageData(videoAsset: 'assets/videos/book.MOV', imageAsset: 'assets/images/book.png', objectName: 'Book'),
    LessonPageData(videoAsset: 'assets/videos/bag.MOV', imageAsset: 'assets/images/bag.png', objectName: 'Bag'),
    LessonPageData(videoAsset: 'assets/videos/clock.MOV', imageAsset: 'assets/images/clock.png', objectName: 'Clock'),
    LessonPageData(videoAsset: 'assets/videos/dog.MOV', imageAsset: 'assets/images/dog.png', objectName: 'Dog'),
    LessonPageData(videoAsset: 'assets/videos/fish.MOV', imageAsset: 'assets/images/fish.png', objectName: 'Fish'),
    LessonPageData(videoAsset: 'assets/videos/table.MOV', imageAsset: 'assets/images/table.png', objectName: 'Table'),
  ],
};

const Color kPrimaryColor = Color(0xFFF58634);
const Color kPrimaryText = Color(0xFF3A3F51);
const Color kBackgroundColor = Color(0xFFFCFCFA);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LevelProgress(),
      child: const ISLApp(),
    ),
  );
}

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

class ISLApp extends StatelessWidget {
  const ISLApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const LevelSelectionScreen(), debugShowCheckedModeBanner: false);
  }
}

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProgress>(
      builder: (context, levelProgress, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const _AppHeader(),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _buildLevelItem(context, 1, levelProgress),
                        const SizedBox(height: 12),
                        _buildLevelItem(context, 2, levelProgress),
                        const SizedBox(height: 12),
                        _buildLevelItem(context, 3, levelProgress),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelItem(BuildContext context, int level, LevelProgress progress) {
    bool isLocked = level > progress.unlockedLevel;
    return Expanded(
      child: LevelButton(
        levelNumber: level,
        isLocked: isLocked,
        onPressed: () {
          Widget screen = (level == 2) ? HiddenObjectGameScreen(level: level) : LevelScreen(level: level);
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, color: kPrimaryText, size: 28),
            SizedBox(width: 8),
            Text('ISL App', style: TextStyle(color: kPrimaryText, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
        Text('Learn Indian Sign Language step by step', style: TextStyle(color: Color(0xFF7B7F8C), fontSize: 14)),
      ],
    );
  }
}

class LevelButton extends StatelessWidget {
  final int levelNumber;
  final bool isLocked;
  final VoidCallback onPressed;
  const LevelButton({Key? key, required this.levelNumber, required this.isLocked, required this.onPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLocked ? null : onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: isLocked ? Color(0xFFF0F0F0) : kPrimaryColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isLocked ? Icons.lock_outline : Icons.play_arrow, color: isLocked ? Color(0xFFB8BCCB) : Colors.white, size: 30),
            Text('Level $levelNumber', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isLocked ? Color(0xFFB8BCCB) : Colors.white)),
            Text(isLocked ? 'Locked' : 'Start Learning', style: TextStyle(fontSize: 16, color: isLocked ? Color(0xFFB8BCCB) : Colors.white70)),
          ],
        ),
      ),
    );
  }
}
