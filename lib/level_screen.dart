import 'dart:async'; // We need this for the Timer
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // To access LevelProgress and colors

// --- 1. UPDATED Data Structure ---
// Now holds all images for the 2-phase animation
class LessonPageData {
  // Phase 1
  final String videoAsset1;
  final String imageAsset1;
  final String objectName1;
  final String videoAsset2;
  final String imageAsset2;
  final String objectName2;

  // Phase 2
  final String prepositionImage1;
  final String prepositionImage2;

  LessonPageData({
    required this.videoAsset1,
    required this.imageAsset1,
    required this.objectName1,
    required this.videoAsset2,
    required this.imageAsset2,
    required this.objectName2,
    required this.prepositionImage1,
    required this.prepositionImage2,
  });
}

// --- 2. UPDATED Mock Data ---
// !! You must add all these images to 'assets/images/' !!
final Map<int, List<LessonPageData>> levelData = {
  1: [
    LessonPageData(
      videoAsset1: 'assets/videos/hello.mov',
      imageAsset1: 'assets/images/hello_img.png', // !! ADD
      objectName1: 'Hello',
      videoAsset2: 'assets/videos/thank_you.mov',
      imageAsset2: 'assets:images/thankyou_img.png', // !! ADD
      objectName2: 'Thank You',
      prepositionImage1: 'assets/images/preposition1.png', // !! ADD
      prepositionImage2: 'assets/images/preposition2.png', // !! ADD
    ),
    LessonPageData(
      videoAsset1: 'assets/videos/water.mov',
      imageAsset1: 'assets/images/water_img.png', // !! ADD
      objectName1: 'Water',
      videoAsset2: 'assets/videos/food.mov',
      imageAsset2: 'assets/images/food_img.png', // !! ADD
      objectName2: 'Food',
      prepositionImage1: 'assets/images/preposition3.png', // !! ADD
      prepositionImage2: 'assets/images/preposition4.png', // !! ADD
    ),
  ],
  // ... add data for other levels
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
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  bool _isLoading = true;
  bool _isPhase2 = false; // Manages which phase we are in
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
    // Start the timer loop
    _startAnimationLoop();
  }

  void _startAnimationLoop() {
    // This timer will fire once and not repeat
    _animationTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) {
        // Check if the widget is still on screen
        setState(() {
          _isPhase2 = true; // Enter Phase 2
        });

        // Start the second timer to reset the loop
        _animationTimer = Timer(const Duration(seconds: 7), () {
          if (mounted) {
            setState(() {
              _isPhase2 = false; // Go back to Phase 1
            });
            _startAnimationLoop(); // Start the loop over
          }
        });
      }
    });
  }

  Future<void> _initializeVideos() async {
    _controller1 = VideoPlayerController.asset(widget.lesson.videoAsset1);
    _controller2 = VideoPlayerController.asset(widget.lesson.videoAsset2);

    try {
      await Future.wait([
        _controller1.initialize(),
        _controller2.initialize(),
      ]);

      _controller1.setLooping(true);
      _controller1.play();
      _controller2.setLooping(true);
      _controller2.play();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _animationTimer?.cancel(); // VERY IMPORTANT: Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    final screenWidth = MediaQuery.of(context).size.width;

    // --- NEW: Animated layout using Stack + AnimatedPositioned ---
    return Stack(
      children: [
        // --- The Main Lesson Content (Phase 1) ---
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: _isPhase2 ? screenWidth * (2 / 3) : screenWidth,
          left: 0,
          top: 0,
          bottom: 0,
          child: Row(
            children: [
              Expanded(
                child: _LessonDetailColumn(
                  controller: _controller1,
                  imageAsset: widget.lesson.imageAsset1,
                  objectName: widget.lesson.objectName1,
                ),
              ),
              VerticalDivider(width: 2.0, color: Colors.grey.shade300),
              Expanded(
                child: _LessonDetailColumn(
                  controller: _controller2,
                  imageAsset: widget.lesson.imageAsset2,
                  objectName: widget.lesson.objectName2,
                ),
              ),
            ],
          ),
        ),

        // --- The Preposition Content (Phase 2) ---
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: screenWidth * (1 / 3),
          // Start off-screen to the right, then slide in
          left: _isPhase2 ? screenWidth * (2 / 3) : screenWidth,
          top: 0,
          bottom: 0,
          child: _PrepositionColumn(
            image1: widget.lesson.prepositionImage1,
            image2: widget.lesson.prepositionImage2,
          ),
        ),
      ],
    );
  }
}

// --- 4. NEW Helper Widget ---
// This displays the two stacked preposition images
class _PrepositionColumn extends StatelessWidget {
  final String image1;
  final String image2;

  const _PrepositionColumn({
    Key? key,
    required this.image1,
    required this.image2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor.withOpacity(0.8), // Slight background
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top preposition image
          Expanded(
            child: Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image.asset(
                image1,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Image not found'));
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom preposition image
          Expanded(
            child: Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image.asset(
                image2,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Image not found'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Lesson Column ---
// This widget displays one lesson (Video + Image + Text)
class _LessonDetailColumn extends StatelessWidget {
  final VideoPlayerController controller;
  final String imageAsset;
  final String objectName;

  const _LessonDetailColumn({
    Key? key,
    required this.controller,
    required this.imageAsset,
    required this.objectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- EDITED: Removed SingleChildScrollView ---
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        // --- EDITED: Added MainAxisAlignment ---
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VideoPlayerCard(
            controller: controller,
            errorText: "Error loading video",
          ),
          // --- EDITED: Reduced spacing ---
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: AspectRatio(
              // --- EDITED: Changed Aspect Ratio ---
              aspectRatio: 16 / 9,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
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
          // --- EDITED: Reduced spacing ---
          const SizedBox(height: 8),
          Text(
            objectName,
            style: const TextStyle(
              // --- EDITED: Reduced font size ---
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- Reusable VideoPlayerCard ---
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
      clipBehavior: Clip.antiAlias,
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
        decoration: BoxDecoration(color: Colors.black),
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

