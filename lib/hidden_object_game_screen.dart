import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'level_screen.dart';

class HiddenObjectGameScreen extends StatefulWidget {
  final int level;
  const HiddenObjectGameScreen({Key? key, required this.level}) : super(key: key);

  @override
  _HiddenObjectGameScreenState createState() => _HiddenObjectGameScreenState();
}

class _HiddenObjectGameScreenState extends State<HiddenObjectGameScreen> {
  VideoPlayerController? _videoController;

  // STRICT ORDER: 1:Ball, 2:Car, 3:Dog, 4:Book, 5:Bicycle, 6:Boat, 7:Bag
  int _currentStage = 1;
  bool _gameStarted = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadStageData();
  }

  // Maps the current stage to your levelData indices
  LessonPageData? get _currentGameData {
    // Ensure levelData[1] contains the objects in this specific order
    return levelData[1]?[_currentStage];
  }

  void _loadStageData() {
    setState(() {
      _isSearching = false;
    });

    _videoController?.dispose();
    if (_currentGameData != null) {
      _videoController = VideoPlayerController.asset(_currentGameData!.videoAsset)
        ..initialize().then((_) {
          setState(() {
            _videoController!.play();
            _videoController!.setLooping(true); // Loop so player can find it whenever
          });
        });
    }
  }

  void _stopVideoAndSearch() {
    if (_videoController != null) {
      _videoController!.pause();
    }
    setState(() {
      _isSearching = true;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _onObjectFound() {
    if (_currentStage < 7) {
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
          // 1. Initial Start Screen
          if (!_gameStarted)
            Center(
              child: ElevatedButton(
                onPressed: () => setState(() => _gameStarted = true),
                child: const Text('Start Level 2 Game', style: TextStyle(fontSize: 24)),
              ),
            ),

          // 2. Video Player Loop
          if (_gameStarted && !_isSearching && _videoController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),

          // 3. Find Object Button (Visible immediately after video starts)
          if (_gameStarted && !_isSearching)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  onPressed: _stopVideoAndSearch,
                  child: const Text('FIND THE OBJECT',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          // 4. Background Scene with Logic-Based Hitboxes
          if (_isSearching)
            Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/images/scene1.png', fit: BoxFit.cover),
                ),

                // THE INVISIBLE BUTTON
                Positioned(
                  left: _getLeftCoordinate(context),
                  top: _getTopCoordinate(context),
                  child: GestureDetector(
                    onTap: _onObjectFound,
                    child: Container(
                      width: 110,
                      height: 110,
                      color: Colors.transparent, // Toggle to red for testing
                    ),
                  ),
                ),
              ],
            ),

          // Back Button
          Positioned(
            top: 10, left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // COORDINATE MAPPING
  double _getLeftCoordinate(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    switch (_currentStage) {
      case 1: return width * 0.58; // Ball
      case 2: return width * 0.45; // Car
      case 3: return width * 0.12; // Dog
      case 4: return width * 0.92; // Book
      case 5: return width * 0.72; // Bicycle
      case 6: return width * 0.05; // Boat
      case 7: return width * 0.78; // Bag
      default: return 0;
    }
  }

  double _getTopCoordinate(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    switch (_currentStage) {
      case 1: return height * 0.68; // Ball
      case 2: return height * 0.58; // Car
      case 3: return height * 0.32; // Dog
      case 4: return height * 0.82; // Book
      case 5: return height * 0.25; // Bicycle
      case 6: return height * 0.72; // Boat
      case 7: return height * 0.58; // Bag
      default: return 0;
    }
  }

  void _showTransitionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Great Job!'),
        content: const Text('You found it! Ready for the next object?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentStage++;
                _loadStageData();
              });
            },
            child: const Text('Continue'),
          )
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: const Text('Amazing! You found all objects in the room!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Provider.of<LevelProgress>(context, listen: false).completeLevel(2);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          )
        ],
      ),
    );
  }
}
