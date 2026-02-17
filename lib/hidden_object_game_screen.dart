import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class HiddenObjectGameScreen extends StatefulWidget {
  final int level;
  const HiddenObjectGameScreen({Key? key, required this.level}) : super(key: key);
  @override
  _HiddenObjectGameScreenState createState() => _HiddenObjectGameScreenState();
}

class _HiddenObjectGameScreenState extends State<HiddenObjectGameScreen> {
  VideoPlayerController? _videoController;
  int _currentStage = 0; // Starts at 0 (Ball)
  bool _gameStarted = false;
  bool _isSearching = false;

  @override
  void initState() { super.initState(); _loadStageData(); }

  LessonPageData? get _currentGameData {
    // Stage logic mapping specifically to Level 1 data list indices
    // index 1=Ball, 2=Car, 3=Boat, 4=Book, 5=Bag
    int dataIndex = _currentStage + 1;
    List<LessonPageData>? currentLevelLessons = levelData[1];
    return (currentLevelLessons != null && dataIndex < currentLevelLessons.length)
        ? currentLevelLessons[dataIndex] : null;
  }

  void _loadStageData() {
    setState(() => _isSearching = false);
    _videoController?.dispose();
    final data = _currentGameData;
    if (data != null) {
      _videoController = VideoPlayerController.asset(data.videoAsset)..initialize().then((_) {
        setState(() { _videoController!.play(); _videoController!.setLooping(true); });
      });
    }
  }

  void _stopVideoAndSearch() { _videoController?.pause(); setState(() => _isSearching = true); }

  @override
  void dispose() { _videoController?.dispose(); super.dispose(); }

  void _onObjectFound() {
    if (_currentStage < 4) { // Finish after Stage 4 (Bag)
      _showTransitionDialog();
    } else {
      _showWinDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (!_gameStarted) Center(child: ElevatedButton(onPressed: () => setState(() => _gameStarted = true), child: const Text('Start Level 2 Game', style: TextStyle(fontSize: 24)))),
          if (_gameStarted && !_isSearching && _videoController != null) Center(child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!))),
          if (_gameStarted && !_isSearching) Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.all(40.0), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: _stopVideoAndSearch, child: const Text('FIND THE OBJECT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))))),
          if (_isSearching) Stack(children: [Positioned.fill(child: Image.asset('assets/images/scene1.png', fit: BoxFit.cover)), Positioned(left: _getLeftCoordinate(context), top: _getTopCoordinate(context), child: GestureDetector(onTap: _onObjectFound, child: Container(width: 110, height: 110, color: Colors.transparent)))]),
          Positioned(top: 10, left: 10, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }

  double _getLeftCoordinate(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    switch (_currentStage) {
      case 0: return width * 0.58; // Ball
      case 1: return width * 0.45; // Car
      case 2: return width * 0.05; // Boat
      case 3: return width * 0.92; // Book
      case 4: return width * 0.78; // Bag
      default: return 0;
    }
  }

  double _getTopCoordinate(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    switch (_currentStage) {
      case 0: return height * 0.68; // Ball
      case 1: return height * 0.58; // Car
      case 2: return height * 0.72; // Boat
      case 3: return height * 0.82; // Book
      case 4: return height * 0.58; // Bag
      default: return 0;
    }
  }

  void _showTransitionDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(title: const Text('Great Job!'), content: const Text('You found it! Ready for the next object?'), actions: [ElevatedButton(onPressed: () { Navigator.pop(context); setState(() { _currentStage++; _loadStageData(); }); }, child: const Text('Continue'))]));
  }

  void _showWinDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(title: const Text('Level Complete!'), content: const Text('Amazing! You found all the objects!'), actions: [ElevatedButton(onPressed: () { Provider.of<LevelProgress>(context, listen: false).completeLevel(2); Navigator.pop(context); Navigator.pop(context); }, child: const Text('Finish'))]));
  }
}
