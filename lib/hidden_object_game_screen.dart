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
  final double width; // Size of the tappable area (as percentage of screen width)
  final double height; // Size of the tappable area (as percentage of screen height)

  HiddenObject({
    required this.name,
    required this.videoPath,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
}

// --- FIX: Converted width and height to ratios ---
// You will need to adjust these ratios to perfectly match your objects!
final List<HiddenObject> level2Objects = [
  HiddenObject(
    name: 'Ball',
    videoPath: 'assets/videos/ball.MOV',
    top: 0.45,
    left: 0.5,
    width: 0.1, // 10% of screen width
    height: 0.15, // 15% of screen height
  ),
  HiddenObject(
    name: 'Car',
    videoPath: 'assets/videos/car.MOV',
    top: 0.40,
    left: 0.43,
    width: 0.1, // 10% of screen width
    height: 0.15, // 15% of screen height
  ),
  HiddenObject(
    name: 'Boat',
    videoPath: 'assets/videos/boat.MOV',
    top: 0.45,
    left: 0.2,
    width: 0.15, // 15% of screen width
    height: 0.2, // 20% of screen height
  ),
  HiddenObject(
    name: 'Book',
    videoPath: 'assets/videos/book.MOV',
    top: 0.55,
    left: 0.7,
    width: 0.1, // 10% of screen width
    height: 0.15, // 15% of screen height
  ),
  HiddenObject(
    name: 'Bicycle',
    videoPath: 'assets/videos/bicycle.MOV',
    top: 0.13,
    left: 0.6,
    width: 0.08, // 15% of screen width
    height: 0.2, // 20% of screen height
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
                'assets/images/scene1.png',
                // --- THIS IS THE FIX ---
                fit: BoxFit.contain,
                // --- END FIX ---
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

            // Responsive tap zone
            Positioned(
              top: level2Objects[_currentObjectIndex].top * screenSize.height,
              left: level2Objects[_currentObjectIndex].left * screenSize.width,
              width: level2Objects[_currentObjectIndex].width * screenSize.width,
              height:
              level2Objects[_currentObjectIndex].height * screenSize.height,
              child: GestureDetector(
                onTap: () => _onObjectTapped(_currentObjectIndex),
                child: Container(
                  // Set to 0 opacity for production
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0),
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