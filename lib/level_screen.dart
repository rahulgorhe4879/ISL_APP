import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class LevelScreen extends StatefulWidget {
  final int level;

  const LevelScreen({Key? key, required this.level})
      : super(key: key);

  @override
  _LevelScreenState createState() =>
      _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final PageController _pageController =
  PageController();

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

  void _goNext() {
    final progress =
    Provider.of<LevelProgress>(context,
        listen: false);

    // 🔥 increment level progress
    progress.incrementLevelProgress(widget.level);

    if (_currentPage < _lessons.length - 1) {
      _pageController.nextPage(
        duration:
        const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      progress.completeLevel(widget.level);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
    Provider.of<LevelProgress>(context);

    final isDark = progress.isDarkMode;

    if (_lessons.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Coming Soon!')),
      );
    }

    double progressValue = progress.getProgress(
        widget.level, _lessons.length);

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF1E293B) : const Color(0xFFFCFCFA),
      body: SafeArea(
        child: Column(
          children: [

            // 🔥 TOP PROGRESS BAR
            Padding(
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 400),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.white24
                        : Colors.grey.shade300,
                    color: isDark
                        ? Colors.indigoAccent
                        : Colors.orange,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Stack(
                children: [

                  // LESSON PAGES
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(
                                () => _currentPage = page),
                    itemCount: _lessons.length,
                    itemBuilder: (context, index) =>
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 20.0),
                          child: LessonVideoCard(
                              lesson: _lessons[index]),
                        ),
                  ),

                  // BACK BUTTON
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () =>
                          Navigator.pop(context),
                    ),
                  ),

                  // LEFT ARROW
                  if (_currentPage > 0)
                    Align(
                      alignment:
                      Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 48,
                          color: Colors.orange,
                        ),
                        onPressed: () =>
                            _pageController
                                .previousPage(
                              duration: const Duration(
                                  milliseconds: 300),
                              curve: Curves.easeIn,
                            ),
                      ),
                    ),

                  // RIGHT / COMPLETE
                  Align(
                    alignment:
                    Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _currentPage ==
                            _lessons.length - 1
                            ? Icons.check_circle
                            : Icons.chevron_right,
                        size: 48,
                        color: _currentPage ==
                            _lessons.length - 1
                            ? Colors.green
                            : Colors.orange,
                      ),
                      onPressed: _goNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- VIDEO CARD ----------------

class LessonVideoCard extends StatefulWidget {
  final LessonPageData lesson;

  const LessonVideoCard({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  _LessonVideoCardState createState() =>
      _LessonVideoCardState();
}

class _LessonVideoCardState
    extends State<LessonVideoCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showImage = false;

  @override
  void initState() {
    super.initState();

    _controller =
    VideoPlayerController.asset(
        widget.lesson.videoAsset)
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
        });

        // Show image after delay
        Future.delayed(
            const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showImage = true;
            });
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
          child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(24),
          border: Border.all(
            color:
            Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: AspectRatio(
          aspectRatio:
          _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius:
                BorderRadius.circular(16),
                child:
                VideoPlayer(_controller),
              ),

              if (_showImage)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.orange,
                        width: 2,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                          12),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .all(6.0),
                      child: Image.asset(
                          widget.lesson
                              .imageAsset),
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