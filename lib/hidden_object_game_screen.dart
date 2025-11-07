import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'main.dart'; // To access LevelProgress and colors

// This class holds the data for a single object to be found
class HiddenObject {
  final String name; // The name of the object
  final String videoPath; // Path to the gesture video
  final double top; // Position from the top (as percentage of screen height)
  final double left; // Position from the left (as percentage of screen width)
  final double width; // Size of the tappable area
  final double height;

  HiddenObject({
    required this.name,
    required this.videoPath,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
}

// List of all objects to find in this level (IN ORDER)
final List<HiddenObject> level2Objects = [
  HiddenObject(
    name: 'Ball',
    videoPath: 'assets/videos/ball.MOV',
    top: 0.3, // 30% from top - ADJUST THESE POSITIONS
    left: 0.2, // 20% from left
    width: 80.0,
    height: 80.0,
  ),
  HiddenObject(
    name: 'Car',
    videoPath: 'assets/videos/car.MOV',
    top: 0.5, // 50% from top - ADJUST THESE POSITIONS
    left: 0.6, // 60% from left
    width: 80.0,
    height: 80.0,
  ),
  HiddenObject(
    name: 'Boat',
    videoPath: 'assets/videos/boat.MOV',
    top: 0.2, // 20% from top - ADJUST THESE POSITIONS
    left: 0.7, // 70% from left
    width: 80.0,
    height: 80.0,
  ),
  HiddenObject(
    name: 'Book',
    videoPath: 'assets/videos/book.MOV',
    top: 0.6, // 60% from top - ADJUST THESE POSITIONS
    left: 0.3, // 30% from left
    width: 80.0,
    height: 80.0,
  ),
  HiddenObject(
    name: 'Bicycle',
    videoPath: 'assets/videos/bicycle.MOV',
    top: 0.4, // 40% from top - ADJUST THESE POSITIONS
    left: 0.5, // 50% from left
    width: 80.0,
    height: 80.0,
  ),
];

class HiddenObjectGameScreen extends StatefulWidget {
  final int level;
  const HiddenObjectGameScreen({Key? key, required this.level})
      : super(key: key);

  @override
  _HiddenObjectGameScreenState createState() => _HiddenObjectGameScreenState();
}

class _HiddenObjectGameScreenState extends State<HiddenObjectGameScreen> {
  int _currentObjectIndex = 0; // Track which object to find next
  bool _allFound = false;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  bool _showGame = false; // Control when to show the game

  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Start by playing the first gesture video
    _playGestureVideo(0);
  }

  Future<void> _playGestureVideo(int index) async {
    if (index >= level2Objects.length) {
      // All objects found
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

    // Dispose previous controller if exists
    await _videoController?.dispose();

    // Create new controller for the current gesture
    _videoController = VideoPlayerController.asset(
      level2Objects[index].videoPath,
    );

    try {
      await _videoController!.initialize();
      setState(() {}); // Rebuild to show video once initialized
      await _videoController!.play();

      // Listen for video completion
      _videoController!.addListener(_videoListener);
    } catch (e) {
      print('Error loading video: $e');
      // If video fails, show the game anyway
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
      // Video finished playing
      _videoController!.removeListener(_videoListener);
      setState(() {
        _isVideoPlaying = false;
        _showGame = true;
      });
    }
  }

  void _onObjectTapped(int tappedIndex) {
    // Check if this is the correct object to find
    if (tappedIndex == _currentObjectIndex) {
      // Correct object found!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You found the ${level2Objects[tappedIndex].name}!'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 1),
        ),
      );

      // Move to next object
      setState(() {
        _currentObjectIndex++;
      });

      // Play next gesture video
      if (_currentObjectIndex < level2Objects.length) {
        _playGestureVideo(_currentObjectIndex);
      } else {
        // All objects found
        setState(() {
          _allFound = true;
          _showGame = false;
        });
      }
    } else {
      // Wrong object tapped
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Try again! Look for the gesture shown.'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _completeLevel() {
    // Reset orientation before leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    Provider.of<LevelProgress>(context, listen: false)
        .completeLevel(widget.level);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Reset orientation when leaving the screen
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
      appBar: AppBar(
        title: Text('Level ${widget.level} - Find the Objects'),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimaryText),
        titleTextStyle: TextStyle(
          color: kPrimaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          // Show video when playing gesture
          if (_isVideoPlaying && _videoController != null)
            Center(
              child: _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator(
                      color: Colors.white,
                    ),
            ),

          // Show game when video is done
          if (_showGame) _buildGameArea(screenSize),

          // Show completion screen when all objects found
          if (_allFound) _buildCompletionScreen(),
        ],
      ),
    );
  }

  Widget _buildGameArea(Size screenSize) {
    return InteractiveViewer(
      maxScale: 3.0,
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Text('Error: Could not load background.png'),
                    ),
                  );
                },
              ),
            ),

            // Only show the CURRENT object as tappable
            Positioned(
              top: level2Objects[_currentObjectIndex].top * screenSize.height,
              left: level2Objects[_currentObjectIndex].left * screenSize.width,
              width: level2Objects[_currentObjectIndex].width,
              height: level2Objects[_currentObjectIndex].height,
              child: GestureDetector(
                onTap: () => _onObjectTapped(_currentObjectIndex),
                child: Container(
                  // Make it slightly visible for debugging (remove color in production)
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.yellow.withOpacity(0.5), width: 2.0),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.yellow
                        .withOpacity(0.1), // Slightly visible for testing
                  ),
                ),
              ),
            ),

            // Progress indicator at the top
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(level2Objects.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _currentObjectIndex
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: index < _currentObjectIndex
                            ? Colors.green
                            : Colors.white,
                        size: 24,
                      ),
                    );
                  }),
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
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.yellow,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Level Complete!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You found all ${level2Objects.length} objects!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _completeLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size(200, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
