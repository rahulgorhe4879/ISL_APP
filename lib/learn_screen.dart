import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'duo_theme.dart';
import 'practice_screen.dart';

class LearnScreen extends StatefulWidget {
  final int lessonIndex;
  const LearnScreen({super.key, required this.lessonIndex});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with TickerProviderStateMixin {
  late LessonPageData _lesson;
  late VideoPlayerController _videoCtrl;
  bool _videoReady = false;
  bool _showIcon = false;
  bool _showContinue = false;
  bool _showXPFlash = false;

  late AnimationController _iconCtrl;
  late Animation<double> _iconScale;
  late AnimationController _xpCtrl;
  late Animation<double> _xpScale;

  @override
  void initState() {
    super.initState();
    _lesson = lessonData[widget.lessonIndex.clamp(0, lessonData.length - 1)];

    _iconCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _iconScale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut));

    _xpCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _xpScale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _xpCtrl, curve: Curves.elasticOut));

    _initVideo();
  }

  void _initVideo() {
    _videoCtrl = VideoPlayerController.asset(_lesson.videoAsset, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _videoReady = true;
          _showContinue = true;
        });
        _videoCtrl.play();

        _videoCtrl.addListener(() {
          if (_videoCtrl.value.position >= _videoCtrl.value.duration && !_showIcon) {
            setState(() => _showIcon = true);
            _iconCtrl.forward();
            HapticFeedback.lightImpact();
            _videoCtrl.setLooping(true);
          }
        });
      });
  }

  void _onContinue() {
    if (_showXPFlash) return;
    HapticFeedback.mediumImpact();
    final state = Provider.of<AppState>(context, listen: false);
    state.completeLesson();
    state.completeNode(10);
    setState(() => _showXPFlash = true);
    _xpCtrl.forward();

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      final nextIdx = state.currentNodeIndex;
      Widget? destination;

      if (nextIdx < pathNodes.length) {
        final node = pathNodes[nextIdx];
        if (node.type == PathNodeType.lesson) {
          destination = LearnScreen(lessonIndex: nextIdx);
        } else {
          if (node.type == PathNodeType.checkpoint) state.completeNode(5);
          destination = const PracticeScreen();
        }
      }

      if (destination != null) {
        Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: const Duration(milliseconds: 350), pageBuilder: (_, __, ___) => destination!, transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child)));
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _videoCtrl.dispose();
    _iconCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                LessonTopBar(progress: (widget.lessonIndex + 1) / 7, onClose: () => Navigator.pop(context)),

                const SizedBox(height: 16),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Duo.r20),
                          border: Border.all(color: isDark ? Colors.white12 : Duo.border, width: 2.5)
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _videoReady
                          ? Stack(
                        children: [
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              child: SizedBox(width: _videoCtrl.value.size.width, height: _videoCtrl.value.size.height, child: VideoPlayer(_videoCtrl)),
                            ),
                          ),
                          if (_showIcon)
                            Positioned(
                              top: 20, right: 20,
                              child: ScaleTransition(
                                scale: _iconScale,
                                child: Container(
                                  width: 120, height: 120,
                                  decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2E3E44) : Duo.white,
                                      borderRadius: BorderRadius.circular(Duo.r16),
                                      border: Border.all(color: Duo.green, width: 3.5),
                                      boxShadow: [BoxShadow(color: Duo.green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))]
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(_lesson.imageAsset, fit: BoxFit.contain),
                                ),
                              ),
                            ),
                        ],
                      )
                          : const Center(child: CircularProgressIndicator(color: Duo.green, strokeWidth: 3)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: ChunkyButton(
                    text: '',
                    icon: Icons.arrow_forward_rounded,
                    color: _showContinue ? Duo.green : (isDark ? const Color(0xFF2E3E44) : Duo.disabled),
                    shadowColor: _showContinue ? Duo.greenDark : (isDark ? const Color(0xFF1F2E35) : Duo.disabledDark),
                    onPressed: _showContinue && !_showXPFlash ? _onContinue : null,
                    height: 56,
                  ),
                ),
              ],
            ),
            if (_showXPFlash)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: ScaleTransition(
                      scale: _xpScale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        decoration: BoxDecoration(color: Duo.gold, borderRadius: BorderRadius.circular(Duo.r20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_rounded, color: Duo.white, size: 34), SizedBox(width: 10), Text('+10 XP', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Duo.white))]),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
