import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // To access LevelProgress and colors

// --- 1. Simplified Data Structure ---
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

// --- 2. Lesson Data ---
final Map<int, List<LessonPageData>> levelData = {
  1: [
    LessonPageData(
      videoAsset: 'assets/videos/ball.MOV',
      imageAsset: 'assets/images/ball.png',
      objectName: 'Ball',
    ),
    LessonPageData(
      videoAsset: 'assets/videos/car.MOV',
      imageAsset: 'assets/images/car.png',
      objectName: 'Car',
    ),
    LessonPageData(
      videoAsset: 'assets/videos/boat.MOV',
      imageAsset: 'assets/images/boat.png',
      objectName: 'Boat',
    ),
    LessonPageData(
      videoAsset: 'assets/videos/book.MOV',
      imageAsset: 'assets/images/book.png',
      objectName: 'Book',
    ),
    LessonPageData(
      videoAsset: 'assets/videos/bicycle.MOV',
      imageAsset: 'assets/images/bicycle.png',
      objectName: 'Bicycle',
    ),
  ],
};
// --- END MOCK DATA ---

// LevelScreen (hosts PageView) - No changes
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
    Provider.of<LevelProgress>(context, listen: false)
        .completeLevel(widget.level);
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
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimaryText),
        titleTextStyle: TextStyle(
            color: kPrimaryText, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _lessons.length,
        itemBuilder: (context, index) {
          return LessonPageWidget(lesson: _lessons[index]);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: isLastPage ? _completeLevel : _nextPage,
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

// --- 3. UPDATED Lesson Page Widget ---
// This now controls the two-phase animation
class LessonPageWidget extends StatefulWidget {
  final LessonPageData lesson;
  const LessonPageWidget({Key? key, required this.lesson}) : super(key: key);

  @override
  _LessonPageWidgetState createState() => _LessonPageWidgetState();
}

class _LessonPageWidgetState extends State<LessonPageWidget> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.lesson.videoAsset);

      // Initialize video
      await _controller.initialize();

      if (!mounted) return;

      // Set up video playback
      _controller.setLooping(true);
      await _controller.setPlaybackSpeed(1.0);
      await _controller.play();

      print(
          'Video initialized: ${_controller.value.isInitialized}, playing: ${_controller.value.isPlaying}');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing video: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().contains('OutOfMemory')
            ? 'Not enough memory to play video. Please restart the app.'
            : 'Error loading video: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    try {
      _controller.pause();
      _controller.dispose();
    } catch (e) {
      print('Error disposing controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error Loading Video',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage.isEmpty
                    ? 'Unable to load video. This may be due to insufficient memory or missing video file.'
                    : _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Simple centered layout with one video
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Video player card
            Card(
              elevation: 6,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(
                      height: 300,
                      decoration: const BoxDecoration(color: Colors.black),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            // Object image
            Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.asset(
                  widget.lesson.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text('Image not found',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: kSecondaryText)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Object name
            Text(
              widget.lesson.objectName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
