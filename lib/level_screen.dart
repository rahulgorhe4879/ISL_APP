// level_screen.dart
import 'dart:async'; // Fixed typo from dart.async to dart:async
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // orientation control
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // To access LevelProgress and colors

// --- Data structure
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

// --- Mock data for level 1 (as you had)
final Map<int, List<LessonPageData>> levelData = {
  1: [
    LessonPageData(videoAsset: 'assets/videos/book.MOV', imageAsset: 'assets/images/book.png', objectName: 'Book'),
    LessonPageData(videoAsset: 'assets/videos/bag.MOV', imageAsset: 'assets/images/bag.png', objectName: 'Bag'),
    LessonPageData(videoAsset: 'assets/videos/car.MOV', imageAsset: 'assets/images/car.png', objectName: 'Car'),
    LessonPageData(videoAsset: 'assets/videos/dog.MOV', imageAsset: 'assets/images/dog.png', objectName: 'Dog'),
    LessonPageData(videoAsset: 'assets/videos/ball.MOV', imageAsset: 'assets/images/ball.png', objectName: 'Ball'),
    LessonPageData(videoAsset: 'assets/videos/bicycle.MOV', imageAsset: 'assets/images/bicycle.png', objectName: 'Bicycle'),
    LessonPageData(videoAsset: 'assets/videos/boat.MOV', imageAsset: 'assets/images/boat.png', objectName: 'Boat'),
    LessonPageData(videoAsset: 'assets/videos/clock.MOV', imageAsset: 'assets/images/clock.png', objectName: 'Clock'),
    LessonPageData(videoAsset: 'assets/videos/fish.MOV', imageAsset: 'assets/images/fish.png', objectName: 'Fish'),
    LessonPageData(videoAsset: 'assets/videos/table.MOV', imageAsset: 'assets/images/table.png', objectName: 'Table'),
  ],
};

// --- LevelScreen ---
class LevelScreen extends StatefulWidget {
  final int level;
  const LevelScreen({super.key, required this.level});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<LessonPageData> _lessons = [];

  @override
  void initState() {
    super.initState();

    // Force landscape when opening this screen (non-await call is fine here)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _lessons = levelData[widget.level] ?? [];
  }

  @override
  void dispose() {
    // Restore default orientations (allow both portrait and landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  // --- NEW METHOD ---
  // Handles resetting orientation and popping the screen
  void _exitScreen() {
    if (!mounted) return;

    // Restore default orientations (allow both portrait and landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.pop(context);
  }

  // --- UPDATED METHOD ---
  void _completeLevel() {
    if (!mounted) return;

    Provider.of<LevelProgress>(context, listen: false).completeLevel(widget.level);
    _exitScreen(); // Use the new exit method
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPage == _lessons.length - 1;

    if (_lessons.isEmpty) {
      return Scaffold(
        // AppBar removed
        body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Coming Soon!'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _exitScreen, // Use exit method here too
                  child: const Text('Go Back'),
                )
              ],
            )),
      );
    }

    // Use SafeArea to avoid status bar overlap and LayoutBuilder for responsiveness
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final maxH = constraints.maxHeight;

            // Responsive sizes
            final navSize = maxH * 0.10;
            final navPadding = maxW * 0.02;
            final arrowIconSize = navSize * 0.42;

            // Sizes for the close button
            final closeButtonSize = (navSize * 0.75).clamp(40.0, 60.0);
            final closeIconSize = closeButtonSize * 0.5;

            return Stack(
              children: [
                // PageView fills safe area
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _lessons.length,
                    itemBuilder: (context, index) {
                      return LessonPageWidget(
                        lesson: _lessons[index],
                        pageIndex: index,
                        currentPageIndex: _currentPage,
                        // Removed level passing as it is no longer shown
                        maxWidth: maxW,
                        maxHeight: maxH,
                      );
                    },
                  ),
                ),

                // LEFT NAV
                if (_currentPage > 0)
                  Positioned(
                    left: navPadding,
                    top: (maxH - navSize) / 2,
                    child: SizedBox(
                      width: navSize,
                      height: navSize,
                      child: Material(
                        color: Colors.black.withAlpha(128),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: arrowIconSize),
                          onPressed: _previousPage,
                          splashRadius: navSize * 0.6,
                        ),
                      ),
                    ),
                  ),

                // RIGHT NAV (or complete button on last page)
                Positioned(
                  right: navPadding,
                  top: (maxH - navSize) / 2,
                  child: SizedBox(
                    width: navSize,
                    height: navSize,
                    child: isLastPage
                        ? Material(
                      color: Colors.green.withAlpha(204),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.check, color: Colors.white, size: arrowIconSize * 0.95),
                        onPressed: _completeLevel,
                        splashRadius: navSize * 0.6,
                      ),
                    )
                        : Material(
                      color: Colors.black.withAlpha(128),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: arrowIconSize),
                        onPressed: _nextPage,
                        splashRadius: navSize * 0.6,
                      ),
                    ),
                  ),
                ),

                // CLOSE (HOME) BUTTON
                Positioned(
                  left: navPadding,
                  top: navPadding, // Position top-left
                  child: SizedBox(
                    width: closeButtonSize,
                    height: closeButtonSize,
                    child: Material(
                      color: Colors.black.withAlpha(128),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: closeIconSize),
                        onPressed: _exitScreen,
                        splashRadius: closeButtonSize * 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- LessonPageWidget (stateful) ---
class LessonPageWidget extends StatefulWidget {
  final LessonPageData lesson;
  final int pageIndex;
  final int currentPageIndex;
  final double maxWidth;
  final double maxHeight;

  const LessonPageWidget({
    super.key,
    required this.lesson,
    required this.pageIndex,
    required this.currentPageIndex,
    // Removed level from constructor
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  State<LessonPageWidget> createState() => _LessonPageWidgetState();
}

class _LessonPageWidgetState extends State<LessonPageWidget> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isPageVisible = false;

  @override
  void initState() {
    super.initState();
    _isPageVisible = widget.pageIndex == widget.currentPageIndex;
    if (_isPageVisible) {
      _initializeAndPlayVideos();
    }
  }

  Future<void> _initializeAndPlayVideos() async {
    if (_controller != null) return;

    try {
      _controller = VideoPlayerController.asset(widget.lesson.videoAsset);
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0.0); // Mute the video
      _controller!.play();
    } catch (e) {
      // Keep the error non-fatal — show fallback UI
      // ignore: avoid_print
      print('!!! ERROR initializing video (${widget.lesson.videoAsset}): $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _disposeVideos() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void didUpdateWidget(covariant LessonPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool isVisible = widget.pageIndex == widget.currentPageIndex;

    if (isVisible && !_isPageVisible) {
      _isLoading = true;
      _initializeAndPlayVideos();
    } else if (!isVisible && _isPageVisible) {
      _disposeVideos();
    }

    _isPageVisible = isVisible;
  }

  @override
  void dispose() {
    _disposeVideos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      if (widget.pageIndex == widget.currentPageIndex) {
        return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
      }
      return const SizedBox.shrink();
    }

    // Use a responsive detail column that receives maxWidth/maxHeight
    return _LessonDetailColumn(
      controller: _controller,
      imageAsset: widget.lesson.imageAsset,
      objectName: widget.lesson.objectName,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
    );
  }
}

// --- Responsive Lesson Detail Column ---
class _LessonDetailColumn extends StatelessWidget {
  final VideoPlayerController? controller;
  final String imageAsset;
  final String objectName;
  final double maxWidth;
  final double maxHeight;

  const _LessonDetailColumn({
    super.key,
    required this.controller,
    required this.imageAsset,
    required this.objectName,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    // responsive measures
    final horizontalPadding = maxWidth * 0.03;
    final verticalPadding = maxHeight * 0.03;

    // thumbnail size
    final thumbMaxWidth = maxWidth * 0.22;
    final thumbWidth = thumbMaxWidth.clamp(100.0, maxWidth * 0.32);
    final thumbHeight = thumbWidth * (3 / 4); // 4:3

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Stack(
        children: [
          // Video
          Positioned.fill(
            child: Card(
              elevation: 6,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: controller != null && controller!.value.isInitialized
                  ? LayoutBuilder(builder: (context, constraints) {
                final availableW = constraints.maxWidth;
                final availableH = constraints.maxHeight;

                final videoAspect = controller!.value.aspectRatio > 0 ? controller!.value.aspectRatio : (4 / 3);
                final expectedHeight = availableW / videoAspect;

                if (expectedHeight <= availableH) {
                  return Center(
                    child: SizedBox(
                      width: availableW,
                      height: expectedHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: controller!.value.size.width,
                            height: controller!.value.size.height,
                            child: VideoPlayer(controller!),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  // constrained by height
                  final expectedWidth = availableH * videoAspect;
                  return Center(
                    child: SizedBox(
                      width: expectedWidth,
                      height: availableH,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: controller!.value.size.width,
                            height: controller!.value.size.height,
                            child: VideoPlayer(controller!),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              })
                  : Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Video Error',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // Top-right thumbnail (image)
          Positioned(
            top: maxHeight * 0.02,
            right: maxWidth * 0.02,
            child: Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: SizedBox(
                width: thumbWidth,
                height: thumbHeight,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.error_outline)),
                    );
                  },
                ),
              ),
            ),
          ),

          // --- REMOVED BOTTOM LABEL HERE ---
        ],
      ),
    );
  }
}