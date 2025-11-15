import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'main.dart'; // To access LevelProgress and colors

// --- Data structure
class HiddenObject {
  final String name;
  final String videoPath;
  final double top; // Percentage of screen height (0.0 to 1.0)
  final double left; // Percentage of screen width (0.0 to 1.0)
  final double width; // Percentage of screen width
  final double height; // Percentage of screen height

  HiddenObject({
    required this.name,
    required this.videoPath,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
}

// --- DATA SETUP ---
final List<HiddenObject> level2Objects = [
  // 1. 'Ball' -> Mapped to Green Cabinet on left
  HiddenObject(
    name: 'Ball',
    videoPath: 'assets/videos/ball.MOV',
    top: 0.40,
    left: 0.15,
    width: 0.20,
    height: 0.25,
  ),
  // 2. 'Car' -> Mapped to Red Mantle
  HiddenObject(
    name: 'Car',
    videoPath: 'assets/videos/car.MOV',
    top: 0.40,
    left: 0.45,
    width: 0.15,
    height: 0.15,
  ),
  // 3. 'Boat' -> Mapped to Red Vase
  HiddenObject(
    name: 'Boat',
    videoPath: 'assets/videos/boat.MOV',
    top: 0.50,
    left: 0.52,
    width: 0.10,
    height: 0.15,
  ),
  // 4. 'Book' -> Mapped to Green Window
  HiddenObject(
    name: 'Book',
    videoPath: 'assets/videos/book.MOV',
    top: 0.30,
    left: 0.65,
    width: 0.15,
    height: 0.25,
  ),
  // 5. 'Bicycle' -> Mapped to Red Pillow
  HiddenObject(
    name: 'Bicycle',
    videoPath: 'assets/videos/bicycle.MOV',
    top: 0.55,
    left: 0.70,
    width: 0.20,
    height: 0.15,
  ),
];

class HiddenObjectGameScreen extends StatefulWidget {
  final int level;
  const HiddenObjectGameScreen({Key? key, required this.level}) : super(key: key);

  @override
  _HiddenObjectGameScreenState createState() => _HiddenObjectGameScreenState();
}

class _HiddenObjectGameScreenState extends State<HiddenObjectGameScreen> {
  // --- SET THIS TO TRUE TO SEE THE CLICK ZONES ---
  final bool _debugMode = true;

  int _currentObjectIndex = 0;
  bool _allFound = false;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  bool _showGame = false;
  bool _showWrongClickOverlay = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _playGestureVideo(0);
  }

  Future<void> _playGestureVideo(int index) async {
    if (index >= level2Objects.length) {
      setState(() {
        _allFound = true;
        _showGame = false;
      });
      return;
    }

    setState(() {
      _isVideoPlaying = true;
      _showGame = false;
    });

    await _videoController?.dispose();
    _videoController = VideoPlayerController.asset(level2Objects[index].videoPath);

    try {
      await _videoController!.initialize();
      setState(() {});
      await _videoController!.play();
      _videoController!.addListener(_videoListener);
    } catch (e) {
      print('Error loading video: $e');
      setState(() {
        _isVideoPlaying = false;
        _showGame = true;
      });
    }
  }

  void _videoListener() {
    if (_videoController != null &&
        !_videoController!.value.isPlaying &&
        _videoController!.value.position >= _videoController!.value.duration) {
      _videoController!.removeListener(_videoListener);
      setState(() {
        _isVideoPlaying = false;
        _showGame = true;
      });
    }
  }

  void _onObjectTapped(int tappedIndex) async {
    if (tappedIndex == _currentObjectIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You found the ${level2Objects[tappedIndex].name}!'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(milliseconds: 1000),
        ),
      );

      setState(() {
        _currentObjectIndex++;
      });

      if (_currentObjectIndex < level2Objects.length) {
        _playGestureVideo(_currentObjectIndex);
      } else {
        setState(() {
          _allFound = true;
          _showGame = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(''),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(milliseconds: 000),
        ),
      );

      // Show red overlay
      setState(() {
        _showWrongClickOverlay = true;
      });
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _showWrongClickOverlay = false;
        });
      }
    }
  }

  void _exitScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.pop(context);
  }

  void _completeLevel() {
    Provider.of<LevelProgress>(context, listen: false).completeLevel(widget.level);
    _exitScreen();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. BACKGROUND & GAME AREA
          Positioned.fill(
            child: _showGame
                ? _buildGameArea(screenSize)
                : Container(color: Colors.black),
          ),

          // 2. VIDEO PLAYER OVERLAY
          if (_isVideoPlaying && _videoController != null)
            Container(
              color: Colors.black,
              child: Center(
                child: _videoController!.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
                    : const CircularProgressIndicator(color: kPrimaryColor),
              ),
            ),

          // 3. COMPLETION SCREEN
          if (_allFound) _buildCompletionScreen(),

          // 4. CLOSE BUTTON
          if (!_allFound && !_isVideoPlaying)
            Positioned(
              top: 20,
              left: 20,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: _exitScreen,
                  ),
                ),
              ),
            ),

          // 5. WRONG CLICK RED OVERLAY
          if (_showWrongClickOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.red.withOpacity(0.2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameArea(Size screenSize) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 3.0,
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            // BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                'assets/images/scene1.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey, child: const Center(child: Text('Image not found'))),
              ),
            ),

            // --- NEW ---
            // DEBUG MODE: Red overlay for the *entire screen*
            if (_debugMode)
              Positioned.fill(
                child: IgnorePointer( // So it doesn't block taps
                  child: Container(
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
              ),

            // HITBOXES
            ...List.generate(level2Objects.length, (index) {
              final obj = level2Objects[index];
              final isCurrentTarget = index == _currentObjectIndex;

              return Positioned(
                top: obj.top * screenSize.height,
                left: obj.left * screenSize.width,
                width: obj.width * screenSize.width,
                height: obj.height * screenSize.height,
                child: GestureDetector(
                  onTap: () => _onObjectTapped(index),
                  child: Container(
                    // --- MODIFIED ---
                    // Only show the GREEN box for the CURRENT target in debug mode
                    // All other boxes (and all boxes in non-debug mode) are transparent
                    decoration: BoxDecoration(
                      border: _debugMode && isCurrentTarget
                          ? Border.all(
                        color: Colors.green,
                        width: 2,
                      )
                          : null,
                      color: _debugMode && isCurrentTarget
                          ? Colors.green.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                ),
              );
            }),

            // PROGRESS INDICATOR (The 5 Stages)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(level2Objects.length, (index) {
                        bool found = index < _currentObjectIndex;
                        bool current = index == _currentObjectIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            found ? Icons.check_circle : (current ? Icons.search : Icons.circle_outlined),
                            color: found ? Colors.green : (current ? Colors.yellow : Colors.white54),
                            size: 24,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.yellow, size: 80),
            const SizedBox(height: 20),
            const Text('Level Complete!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _completeLevel,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text('Continue', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}