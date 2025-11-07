import 'dart:async'; // We need this for the Timer
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // To access LevelProgress and colors

// --- 1. SIMPLIFIED Data Structure ---
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

// --- 2. UPDATED Mock Data (10 pages for Level 1) ---
final Map<int, List<LessonPageData>> levelData = {
  1: [
    // Page 1
    LessonPageData(
      videoAsset: 'assets/videos/book.MOV',
      imageAsset: 'assets/images/book.png',
      objectName: 'Book',
    ),
    // Page 2
    LessonPageData(
      videoAsset: 'assets/videos/bag.MOV',
      imageAsset: 'assets/images/bag.png',
      objectName: 'Bag',
    ),
    // Page 3
    LessonPageData(
      videoAsset: 'assets/videos/car.MOV',
      imageAsset: 'assets/images/car.png',
      objectName: 'Car',
    ),
    // Page 4
    LessonPageData(
      videoAsset: 'assets/videos/dog.MOV',
      imageAsset: 'assets/images/dog.png',
      objectName: 'Dog',
    ),
    // Page 5
    LessonPageData(
      videoAsset: 'assets/videos/ball.MOV',
      imageAsset: 'assets/images/ball.png',
      objectName: 'Ball',
    ),
    // Page 6
    LessonPageData(
      videoAsset: 'assets/videos/bicycle.MOV',
      imageAsset: 'assets/images/bicycle.png',
      objectName: 'bicycle',
    ),
    // Page 7
    LessonPageData(
      videoAsset: 'assets/videos/boat.MOV',
      imageAsset: 'assets/images/boat.png',
      objectName: ' Boat',
    ),
    // Page 8
    LessonPageData(
      videoAsset: 'assets/videos/clock.MOV',
      imageAsset: 'assets/images/clock.png',
      objectName: 'Clock',
    ),
    // Page 9
    LessonPageData(
      videoAsset: 'assets/videos/fish.MOV',
      imageAsset: 'assets/images/fish.png',
      objectName: 'Fish',
    ),
    // Page 10
    LessonPageData(
      videoAsset: 'assets/videos/table.MOV',
      imageAsset: 'assets/images/table.png',
      objectName: 'Table',
    ),
  ],
  // ... add data for other levels
};
// --- END MOCK DATA ---

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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _completeLevel() {
    if (!mounted) return;
    Provider.of<LevelProgress>(context, listen: false)
        .completeLevel(widget.level);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // This will now be true on page 10
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
        iconTheme: const IconThemeData(color: kPrimaryText),
        titleTextStyle: const TextStyle(
            color: kPrimaryText, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _lessons.length,
            itemBuilder: (context, index) {
              return LessonPageWidget(
                lesson: _lessons[index],
                pageIndex: index,
                currentPageIndex: _currentPage,
              );
            },
          ),

          if (_currentPage > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withAlpha(128),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: _previousPage,
                  ),
                ),
              ),
            ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLastPage
                  ? Tooltip(
                message: 'Complete Level',
                child: CircleAvatar(
                  backgroundColor: Colors.green.withAlpha(204),
                  child: IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: _completeLevel,
                  ),
                ),
              )
                  : CircleAvatar(
                backgroundColor: Colors.black.withAlpha(128),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                  onPressed: _nextPage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. SIMPLIFIED Lesson Page Widget ---
class LessonPageWidget extends StatefulWidget {
  final LessonPageData lesson;
  final int pageIndex;
  final int currentPageIndex;

  const LessonPageWidget({
    super.key,
    required this.lesson,
    required this.pageIndex,
    required this.currentPageIndex,
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
      _controller!.play();
    } catch (e) {
      print('!!! ERROR initializing video (${widget.lesson.videoAsset}): $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _disposeVideos() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void didUpdateWidget(LessonPageWidget oldWidget) {
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

    // --- EDITED: Removed Center and FractionallySizedBox ---
    // The _LessonDetailColumn will now fill the PageView
    return _LessonDetailColumn(
      controller: _controller,
      imageAsset: widget.lesson.imageAsset,
      objectName: widget.lesson.objectName,
    );
  }
}

// --- 4. SIMPLIFIED Lesson Detail Column (Stack) ---
class _LessonDetailColumn extends StatelessWidget {
  final VideoPlayerController? controller;
  final String imageAsset;
  final String objectName;

  const _LessonDetailColumn({
    super.key,
    required this.controller,
    required this.imageAsset,
    required this.objectName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // --- EDITED: Changed padding to be symmetrical ---
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Stack(
        children: [
          VideoPlayerCard(
            controller: controller,
            errorText: "Video Error",
          ),

          Positioned(
            top: 8,
            right: 8,
            child: Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                height: 80,
                width: 100,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.error_outline, color: kSecondaryText),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                objectName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. Reusable VideoPlayerCard ---
class VideoPlayerCard extends StatelessWidget {
  final VideoPlayerController? controller;
  final String errorText;

  const VideoPlayerCard({
    super.key,
    required this.controller,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // --- EDITED: This code will force the video to fill the card ---
      child: (controller != null && controller!.value.isInitialized)
          ? SizedBox.expand( // Fills the card
        child: FittedBox(
          fit: BoxFit.cover, // Zooms/crops to fill
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: ClipRRect( // Clip to the rounded corners
              borderRadius: BorderRadius.circular(16.0),
              child: VideoPlayer(controller!),
            ),
          ),
        ),
      )
          : Container(
        // No fixed height, let the card size it
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16.0),
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