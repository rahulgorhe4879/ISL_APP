import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart';

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

// --- UPDATED DATA WITH NEW ASSETS ---
final Map<int, List<LessonPageData>> levelData = {
  1: [
    LessonPageData(videoAsset: 'assets/videos/bicycle.MOV', imageAsset: 'assets/images/bicycle.png', objectName: 'Bicycle'),
    LessonPageData(videoAsset: 'assets/videos/ball.MOV', imageAsset: 'assets/images/ball.png', objectName: 'Ball'),
    LessonPageData(videoAsset: 'assets/videos/car.MOV', imageAsset: 'assets/images/car.png', objectName: 'Car'),
    LessonPageData(videoAsset: 'assets/videos/boat.MOV', imageAsset: 'assets/images/boat.png', objectName: 'Boat'),
    LessonPageData(videoAsset: 'assets/videos/book.MOV', imageAsset: 'assets/images/book.png', objectName: 'Book'),
    // NEW ITEMS ADDED BELOW
    LessonPageData(videoAsset: 'assets/videos/bag.MOV', imageAsset: 'assets/images/bag.png', objectName: 'Bag'),
    LessonPageData(videoAsset: 'assets/videos/clock.MOV', imageAsset: 'assets/images/clock.png', objectName: 'Clock'),
    LessonPageData(videoAsset: 'assets/videos/dog.MOV', imageAsset: 'assets/images/dog.png', objectName: 'Dog'),
    LessonPageData(videoAsset: 'assets/videos/fish.MOV', imageAsset: 'assets/images/fish.png', objectName: 'Fish'),
    LessonPageData(videoAsset: 'assets/videos/table.MOV', imageAsset: 'assets/images/table.png', objectName: 'Table'),
  ],
};

class LevelScreen extends StatefulWidget {
  final int level;
  const LevelScreen({Key? key, required this.level}) : super(key: key);

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<List<LessonPageData>> _lessonPairs = [];

  @override
  void initState() {
    super.initState();
    List<LessonPageData> rawLessons = levelData[widget.level] ?? [];
    // Group lessons into pairs for side-by-side display
    for (var i = 0; i < rawLessons.length; i += 2) {
      _lessonPairs.add(
          rawLessons.sublist(i, i + 2 > rawLessons.length ? rawLessons.length : i + 2)
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lessonPairs.isEmpty) return const Scaffold(body: Center(child: Text('Coming Soon!')));

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFA),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: _lessonPairs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    children: _lessonPairs[index].map((lesson) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: LessonVideoCard(lesson: lesson),
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
            // UI Controls
            Positioned(
              top: 10, left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (_currentPage > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 48, color: Color(0xFFF58634)),
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  _currentPage == _lessonPairs.length - 1 ? Icons.check_circle : Icons.chevron_right,
                  size: 48,
                  color: _currentPage == _lessonPairs.length - 1 ? Colors.green : const Color(0xFFF58634),
                ),
                onPressed: () {
                  if (_currentPage < _lessonPairs.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  } else {
                    Provider.of<LevelProgress>(context, listen: false).completeLevel(widget.level);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonVideoCard extends StatefulWidget {
  final LessonPageData lesson;
  const LessonVideoCard({Key? key, required this.lesson}) : super(key: key);

  @override
  _LessonVideoCardState createState() => _LessonVideoCardState();
}

class _LessonVideoCardState extends State<LessonVideoCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.lesson.videoAsset)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
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
    if (!_isInitialized) return const Center(child: CircularProgressIndicator());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.lesson.objectName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3A3F51))),
        const SizedBox(height: 10),
        // Flexible prevents the video from pushing off the screen and causing overflow
        Flexible(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(widget.lesson.imageAsset),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
