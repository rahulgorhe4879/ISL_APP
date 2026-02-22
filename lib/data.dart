import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────────

class LessonPageData {
  final String videoAsset;
  final String imageAsset;
  final String objectName;

  const LessonPageData({
    required this.videoAsset,
    required this.imageAsset,
    required this.objectName,
  });
}

enum PathNodeType { lesson, checkpoint, practice }

class PathNodeData {
  final double xPercent; // 0.0 – 1.0 horizontal position
  final PathNodeType type;
  final String label;
  final IconData icon;

  const PathNodeData({
    required this.xPercent,
    required this.type,
    required this.label,
    required this.icon,
  });
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int target;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
  });
}

// ─────────────────────────────────────────────────
//  LEVEL DATA
// ─────────────────────────────────────────────────

const List<LessonPageData> lessonData = [
  LessonPageData(videoAsset: 'assets/videos/bicycle.MOV', imageAsset: 'assets/images/bicycle.png', objectName: 'Bicycle'),
  LessonPageData(videoAsset: 'assets/videos/ball.MOV', imageAsset: 'assets/images/ball.png', objectName: 'Ball'),
  LessonPageData(videoAsset: 'assets/videos/car.MOV', imageAsset: 'assets/images/car.png', objectName: 'Car'),
  LessonPageData(videoAsset: 'assets/videos/boat.MOV', imageAsset: 'assets/images/boat.png', objectName: 'Boat'),
  LessonPageData(videoAsset: 'assets/videos/book.MOV', imageAsset: 'assets/images/book.png', objectName: 'Book'),
];

// Practice stage data (reuses lesson data for video prompts)
const List<LessonPageData> practiceData = [
  LessonPageData(videoAsset: 'assets/videos/ball.MOV', imageAsset: 'assets/images/ball.png', objectName: 'Ball'),
  LessonPageData(videoAsset: 'assets/videos/car.MOV', imageAsset: 'assets/images/car.png', objectName: 'Car'),
  LessonPageData(videoAsset: 'assets/videos/boat.MOV', imageAsset: 'assets/images/boat.png', objectName: 'Boat'),
  LessonPageData(videoAsset: 'assets/videos/book.MOV', imageAsset: 'assets/images/book.png', objectName: 'Book'),
  LessonPageData(videoAsset: 'assets/videos/bag.MOV', imageAsset: 'assets/images/bag.png', objectName: 'Bag'),
];

// Path nodes define the winding S-curve on the home screen
const List<PathNodeData> pathNodes = [
  PathNodeData(xPercent: 0.50, type: PathNodeType.lesson, label: 'Bicycle', icon: Icons.pedal_bike),
  PathNodeData(xPercent: 0.62, type: PathNodeType.lesson, label: 'Ball', icon: Icons.sports_soccer),
  PathNodeData(xPercent: 0.70, type: PathNodeType.lesson, label: 'Car', icon: Icons.directions_car),
  PathNodeData(xPercent: 0.58, type: PathNodeType.lesson, label: 'Boat', icon: Icons.sailing),
  PathNodeData(xPercent: 0.40, type: PathNodeType.lesson, label: 'Book', icon: Icons.menu_book),
  PathNodeData(xPercent: 0.28, type: PathNodeType.checkpoint, label: 'Review', icon: Icons.star),
  PathNodeData(xPercent: 0.42, type: PathNodeType.practice, label: 'Practice', icon: Icons.search),
];

// Achievements
const List<Achievement> achievements = [
  Achievement(title: 'First Step', description: 'Complete your first lesson', icon: Icons.flag, color: Color(0xFF58CC02), target: 1),
  Achievement(title: 'Quick Learner', description: 'Complete all 5 sign lessons', icon: Icons.school, color: Color(0xFF1CB0F6), target: 5),
  Achievement(title: 'Sharp Eye', description: 'Complete the practice game', icon: Icons.visibility, color: Color(0xFFFF9600), target: 1),
  Achievement(title: 'Perfect Score', description: 'Finish practice with all 3 hearts', icon: Icons.favorite, color: Color(0xFFFF4B4B), target: 1),
];

// ─────────────────────────────────────────────────
//  APP STATE
// ─────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  String userName = '';
  int _currentNodeIndex = 0; // furthest unlocked node (0-based)
  int totalXP = 0;
  int streak = 1;
  int gems = 0;
  int lessonsCompleted = 0;
  int practiceCompleted = 0;
  bool practiceCompletedPerfect = false;
  bool showWordsInLesson = true; // toggle for showing object name in Level 1

  int get currentNodeIndex => _currentNodeIndex;

  void setUserName(String name) {
    userName = name;
    notifyListeners();
  }

  void toggleShowWords() {
    showWordsInLesson = !showWordsInLesson;
    notifyListeners();
  }
  int get totalNodes => pathNodes.length;

  bool isNodeUnlocked(int index) => index <= _currentNodeIndex;
  bool isNodeCompleted(int index) => index < _currentNodeIndex;
  bool isNodeActive(int index) => index == _currentNodeIndex;

  void completeNode(int xpEarned) {
    if (_currentNodeIndex < pathNodes.length - 1) {
      _currentNodeIndex++;
    }
    totalXP += xpEarned;
    notifyListeners();
  }

  void completeLesson() {
    lessonsCompleted++;
    notifyListeners();
  }

  void completePractice({bool perfect = false}) {
    practiceCompleted++;
    if (perfect) practiceCompletedPerfect = true;
    notifyListeners();
  }

  void addXP(int amount) {
    totalXP += amount;
    gems += (amount ~/ 10);
    notifyListeners();
  }

  // Reset node to allow replaying Level 1 on game over
  void resetToLevel1() {
    // Move back to first lesson node if currently past checkpoint
    if (_currentNodeIndex > 5) {
      _currentNodeIndex = 5; // checkpoint stays completed, practice unlocked but restartable
    }
    notifyListeners();
  }

  // Achievement progress
  int getAchievementProgress(int achievementIndex) {
    switch (achievementIndex) {
      case 0: return lessonsCompleted.clamp(0, 1); // First Step
      case 1: return lessonsCompleted.clamp(0, 5); // Quick Learner
      case 2: return practiceCompleted.clamp(0, 1); // Sharp Eye
      case 3: return practiceCompletedPerfect ? 1 : 0; // Perfect Score
      default: return 0;
    }
  }
}
