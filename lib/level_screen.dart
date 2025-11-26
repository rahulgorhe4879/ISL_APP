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

// LevelScreen (hosts PageView)
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
    } else {
      // If on last page, complete the level
      _completeLevel();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
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
    bool isFirstPage = _currentPage == 0;

    // Handle empty lessons case
    if (_lessons.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            const Center(child: Text('Coming Soon!')),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: The Content (PageView)
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                return LessonPageWidget(lesson: _lessons[index]);
              },
            ),

            // Layer 2: Custom Top-Left Back Button (To exit level)
            Positioned(
              top: 10,
              left: 10,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ),

            // Layer 3: Left Navigation Arrow (<) - Vertically Centered
            if (!isFirstPage)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: InkWell(
                    onTap: _previousPage,
                    child: Container(
                      padding: const EdgeInsets.all(12), // Size of the button
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left, // The < icon
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),

            // Layer 4: Right Navigation Arrow (>) - Vertically Centered
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // Green on last page to indicate "Done", Orange otherwise
                      color: isLastPage
                          ? Colors.green.shade600
                          : kPrimaryColor.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(
                      // Checkmark if last page, > if not
                      isLastPage ? Icons.check : Icons.chevron_right,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar is REMOVED
    );
  }
}

// --- 3. Lesson Page Widget (Unchanged from previous best version) ---
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
      await _controller.initialize();
      if (!mounted) return;
      _controller.setLooping(true);
      await _controller.setPlaybackSpeed(1.0);
      await _controller.play();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (_hasError) {
      return Center(child: Text(_errorMessage.isEmpty ? 'Error' : _errorMessage));
    }

    // Get screen size to determine max video height
    final size = MediaQuery.of(context).size;
    final double maxVideoHeight = size.height * 0.75;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxVideoHeight,
          maxWidth: size.width * 0.90, // Leave space for side buttons
        ),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // 1. The Video Player
              Card(
                elevation: 6,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: VideoPlayer(_controller),
              ),

              // 2. The Small Image Overlay (Square)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.lesson.imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.grey);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
