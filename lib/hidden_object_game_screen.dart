import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class HiddenObjectGameScreen extends StatefulWidget {
  final int level;

  const HiddenObjectGameScreen({
    Key? key,
    required this.level,
  }) : super(key: key);

  @override
  _HiddenObjectGameScreenState createState() =>
      _HiddenObjectGameScreenState();
}

class _HiddenObjectGameScreenState
    extends State<HiddenObjectGameScreen> {
  VideoPlayerController? _videoController;

  int _currentStage = 0;
  bool _gameStarted = false;
  bool _isSearching = false;
  bool _showCorrectOverlay = false;
  bool _showWrongOverlay = false;

  @override
  void initState() {
    super.initState();
    _loadStageData();
  }

  LessonPageData? get _currentGameData {
    int dataIndex = _currentStage + 1;
    List<LessonPageData>? currentLevelLessons =
    levelData[1];

    return (currentLevelLessons != null &&
        dataIndex <
            currentLevelLessons.length)
        ? currentLevelLessons[dataIndex]
        : null;
  }

  void _loadStageData() {
    setState(() {
      _isSearching = false;
      _showCorrectOverlay = false;
    });

    _videoController?.dispose();

    final data = _currentGameData;

    if (data != null) {
      _videoController =
      VideoPlayerController.asset(
          data.videoAsset)
        ..initialize().then((_) {
          if (!mounted) return;

          setState(() {
            _videoController!
                .setLooping(true);
            _videoController!.play();
          });
        });
    }
  }

  void _enterSearchMode() {
    _videoController?.pause();
    setState(() {
      _isSearching = true;
    });
  }

  void _onObjectFound() {
    final progress =
    Provider.of<LevelProgress>(
        context,
        listen: false);

    progress.addHeart(); // ❤️ +1
    progress.incrementLevelProgress(
        2); // 🔥 TRACK PROGRESS

    setState(() {
      _showCorrectOverlay = true;
    });

    Future.delayed(
        const Duration(seconds: 1), () {
      if (!mounted) return;

      if (_currentStage < 4) {
        setState(() {
          _currentStage++;
          _loadStageData();
        });
      } else {
        _showWinDialog();
      }
    });
  }

  void _onWrongTap() {
    final progress =
    Provider.of<LevelProgress>(
        context,
        listen: false);

    progress.removeHeart(); // 💔 -1

    setState(() {
      _showWrongOverlay = true;
    });

    Future.delayed(
        const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showWrongOverlay = false;
        });
      }
    });

    if (progress.hearts == 0) {
      progress.lockLevel(2);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "No hearts left! Level 2 locked."),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hearts =
        Provider.of<LevelProgress>(context)
            .hearts;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ❤️ HEART DISPLAY
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 6),
                Text(
                  '$hearts',
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                )
              ],
            ),
          ),

          // START BUTTON
          if (!_gameStarted)
            Center(
              child: ElevatedButton(
                onPressed: () =>
                    setState(() =>
                    _gameStarted =
                    true),
                child: const Text(
                  'Start Game',
                  style: TextStyle(
                      fontSize: 24),
                ),
              ),
            ),

          // VIDEO MODE
          if (_gameStarted &&
              !_isSearching &&
              _videoController != null)
            Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio:
                    _videoController!
                        .value.aspectRatio,
                    child: VideoPlayer(
                        _videoController!),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 40,
                  child: GestureDetector(
                    onTap:
                    _enterSearchMode,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration:
                      const BoxDecoration(
                        color:
                        Colors.green,
                        shape:
                        BoxShape
                            .circle,
                      ),
                      child:
                      const Icon(
                        Icons.check,
                        color: Colors
                            .white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // SEARCH MODE
          if (_isSearching)
            GestureDetector(
              onTap:
              _onWrongTap,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/scene1.png',
                      fit:
                      BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left:
                    _getLeftCoordinate(
                        context),
                    top:
                    _getTopCoordinate(
                        context),
                    child:
                    GestureDetector(
                      onTap:
                      _onObjectFound,
                      child: Container(
                        width: 110,
                        height: 110,
                        color: Colors
                            .transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // CORRECT OVERLAY
          if (_showCorrectOverlay)
            Container(
              color: Colors.black54,
              child:
              const Center(
                child: Text(
                  "✔ CORRECT!",
                  style: TextStyle(
                    color:
                    Colors.green,
                    fontSize: 50,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),
            ),

          // WRONG OVERLAY
          if (_showWrongOverlay)
            Center(
              child: Container(
                padding:
                const EdgeInsets
                    .all(20),
                decoration:
                BoxDecoration(
                  color:
                  Colors.black87,
                  borderRadius:
                  BorderRadius
                      .circular(12),
                ),
                child: const Text(
                  "-1 ❤️ Wrong!",
                  style: TextStyle(
                    color:
                    Colors.red,
                    fontSize: 28,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),
            ),

          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color:
                Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(
                      context),
            ),
          ),
        ],
      ),
    );
  }

  double _getLeftCoordinate(
      BuildContext context) {
    final width =
        MediaQuery.of(context)
            .size
            .width;

    switch (_currentStage) {
      case 0:
        return width * 0.58;
      case 1:
        return width * 0.45;
      case 2:
        return width * 0.05;
      case 3:
        return width * 0.92;
      case 4:
        return width * 0.78;
      default:
        return 0;
    }
  }

  double _getTopCoordinate(
      BuildContext context) {
    final height =
        MediaQuery.of(context)
            .size
            .height;

    switch (_currentStage) {
      case 0:
        return height * 0.68;
      case 1:
        return height * 0.58;
      case 2:
        return height * 0.72;
      case 3:
        return height * 0.82;
      case 4:
        return height * 0.58;
      default:
        return 0;
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible:
      false,
      builder: (context) =>
          AlertDialog(
            title:
            const Text(
                'Level Complete!'),
            content:
            const Text(
                'Amazing! You found all the objects!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Provider.of<
                      LevelProgress>(
                      context,
                      listen:
                      false)
                      .completeLevel(
                      2);
                  Navigator.pop(
                      context);
                  Navigator.pop(
                      context);
                },
                child:
                const Text('Finish'),
              )
            ],
          ),
    );
  }
}