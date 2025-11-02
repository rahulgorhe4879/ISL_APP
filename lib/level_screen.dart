import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // To access LevelProgress and colors

// This data structure holds the content for each "page" in your level
class LessonPageData {
  final String videoAsset1;
  final String videoAsset2;
  final String objectName;
  LessonPageData({
    required this.videoAsset1,
    required this.videoAsset2,
    required this.objectName,
  });
}

// --- MOCK DATA ---
// Replace these with your actual asset paths
final Map<int, List<LessonPageData>> levelData = {
  1: [
    LessonPageData(
      videoAsset1: 'assets/videos/hello.mov', // !! REPLACE THIS
      videoAsset2: 'assets/videos/thank_you.mov', // !! REPLACE THIS
      objectName: 'Hello & Thank You',
    ),
    LessonPageData(
      videoAsset1: 'assets/videos/water.mov', // !! REPLACE THIS
      videoAsset2: 'assets:videos/food.mov', // !! REPLACE THIS
      objectName: 'Water & Food',
    ),
  ],
  2: [
    // Add data for level 2
    LessonPageData(
      videoAsset1: 'assets/videos/placeholder.mov', // !! REPLACE THIS
      videoAsset2: 'assets/videos/placeholder.mov', // !! REPLACE THIS
      objectName: 'Level 2 - Page 1',
    ),
  ],
  // Add more levels...
};
// --- END MOCK DATA ---

class LevelScreen extends StatefulWidget {
  final int level;
  const LevelScreen({Key? key, required this.level}) : super(key: key);

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<LessonPageData> _lessons = [];

  @override
  void initState() {
    super.initState();
    // Load the lessons for the current level
    _lessons = levelData[widget.level] ?? [];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _lessons.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _completeLevel() {
    // Use Provider to mark the level as complete
    Provider.of<LevelProgress>(context, listen: false)
        .completeLevel(widget.level);
    // Go back to the level selection screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPage == _lessons.length - 1;

    if (_lessons.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Level ${widget.level}')),
        body: const Center(
          child: Text('Coming Soon!'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Level ${widget.level} - Page ${_currentPage + 1}/${_lessons.length}'),
        backgroundColor: kBackgroundColor, // Match new theme
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimaryText), // Match new theme
        titleTextStyle: TextStyle( // Match new theme
            color: kPrimaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _lessons.length,
        itemBuilder: (context, index) {
          return LessonPageWidget(lesson: _lessons[index]);
        },
      ),
      // Bottom button for navigation
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: isLastPage ? _completeLevel : _nextPage,
          // --- NEW: Styled Button ---
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastPage ? Colors.green.shade700 : kPrimaryColor,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(isLastPage ? 'Complete Level' : 'Next Page'),
        ),
      ),
    );
  }
}

// This widget holds the 2 videos and plays them
class LessonPageWidget extends StatefulWidget {
  final LessonPageData lesson;
  const LessonPageWidget({Key? key, required this.lesson}) : super(key: key);

  @override
  _LessonPageWidgetState createState() => _LessonPageWidgetState();
}

class _LessonPageWidgetState extends State<LessonPageWidget> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    // IMPORTANT: For local assets, use VideoPlayerController.asset()
    _controller1 = VideoPlayerController.asset(widget.lesson.videoAsset1);
    _controller2 = VideoPlayerController.asset(widget.lesson.videoAsset2);

    try {
      // Wait for both controllers to initialize
      await Future.wait([
        _controller1.initialize(),
        _controller2.initialize(),
      ]);

      // Set looping and play
      _controller1.setLooping(true);
      _controller1.play();

      _controller2.setLooping(true);
      _controller2.play();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing videos: $e');
      // Handle error, e.g., show a placeholder
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // VERY IMPORTANT: Dispose controllers to free up resources
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    // --- NEW: Added SingleChildScrollView to prevent overflow ---
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- NEW: Video player in a styled Card ---
          VideoPlayerCard(
              controller: _controller1, errorText: "Error loading video 1"),
          const SizedBox(height: 16),
          VideoPlayerCard(
              controller: _controller2, errorText: "Error loading video 2"),
          const SizedBox(height: 32),

          // --- NEW: Styled object name ---
          Text(
            widget.lesson.objectName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kPrimaryText, // Use new theme text color
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- NEW: Extracted a reusable widget for the video player ---
class VideoPlayerCard extends StatelessWidget {
  final VideoPlayerController controller;
  final String errorText;

  const VideoPlayerCard({
    Key? key,
    required this.controller,
    required this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: (controller.value.isInitialized)
          ? AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      )
          : Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Center(
          child: Text(
            errorText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

