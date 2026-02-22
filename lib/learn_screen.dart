import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'duo_theme.dart';
import 'practice_screen.dart';

// ═══════════════════════════════════════════════════
//  LEVEL 1 — LEARN SCREEN
//  Auto-advances through all lessons → practice
//  No per-lesson celebration screen
// ═══════════════════════════════════════════════════

class LearnScreen extends StatefulWidget {
  final int lessonIndex;
  const LearnScreen({super.key, required this.lessonIndex});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with TickerProviderStateMixin {
  late LessonPageData _lesson;
  late VideoPlayerController _videoCtrl;
  bool _videoReady = false;
  bool _showIcon = false;
  bool _showContinue = false;
  bool _showXPFlash = false;

  late AnimationController _iconCtrl;
  late Animation<double> _iconScale;

  late AnimationController _continueCtrl;
  late Animation<Offset> _continueSlide;

  late AnimationController _xpCtrl;
  late Animation<double> _xpScale;

  @override
  void initState() {
    super.initState();
    _lesson = lessonData[widget.lessonIndex.clamp(0, lessonData.length - 1)];

    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _iconScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut));

    _continueCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _continueSlide = Tween<Offset>(
            begin: const Offset(0, 1.5), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _continueCtrl, curve: Curves.easeOutBack));

    _xpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _xpScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _xpCtrl, curve: Curves.elasticOut));

    _initVideo();
  }

  void _initVideo() {
    _videoCtrl = VideoPlayerController.asset(
      _lesson.videoAsset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _videoCtrl.setLooping(true);
        _videoCtrl.setVolume(0);
        _videoCtrl.play();

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => _showIcon = true);
          _iconCtrl.forward();
          HapticFeedback.lightImpact();

          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            setState(() => _showContinue = true);
            _continueCtrl.forward();
          });
        });
      });
  }

  void _onContinue() {
    if (_showXPFlash) return; // already advancing
    HapticFeedback.mediumImpact();

    final state = Provider.of<AppState>(context, listen: false);
    state.completeLesson();
    state.completeNode(10);

    // Show +XP flash
    setState(() => _showXPFlash = true);
    _xpCtrl.forward();

    // Auto-advance after flash
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;

      final nextIdx = state.currentNodeIndex;
      Widget? destination;

      if (nextIdx < pathNodes.length) {
        final node = pathNodes[nextIdx];
        if (node.type == PathNodeType.lesson) {
          destination = LearnScreen(lessonIndex: nextIdx);
        } else {
          // Skip checkpoint automatically, go straight to practice
          if (node.type == PathNodeType.checkpoint) {
            state.completeNode(5);
          }
          destination = const PracticeScreen();
        }
      }

      if (destination != null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => destination!,
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _videoCtrl.dispose();
    _iconCtrl.dispose();
    _continueCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.lessonIndex + 1) / lessonData.length;

    return Scaffold(
      backgroundColor: Duo.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── MAIN CONTENT ──
            Column(
              children: [
                LessonTopBar(
                  progress: progress,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),

                // Lesson counter + instruction
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lesson ${widget.lessonIndex + 1} of ${lessonData.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Duo.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Watch the sign carefully',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Duo.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── VIDEO CARD ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Duo.cardBg,
                        borderRadius: BorderRadius.circular(Duo.r20),
                        border: Border.all(color: Duo.border, width: 2.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _videoReady
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(Duo.r20 - 2),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoCtrl.value.size.width,
                                      height: _videoCtrl.value.size.height,
                                      child: VideoPlayer(_videoCtrl),
                                    ),
                                  ),
                                ),
                                // Icon pop-up top-right
                                if (_showIcon)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: ScaleTransition(
                                      scale: _iconScale,
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Duo.white,
                                          borderRadius:
                                              BorderRadius.circular(Duo.r12),
                                          border: Border.all(
                                              color: Duo.green, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Duo.green
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(
                                            _lesson.imageAsset,
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                  color: Duo.green, strokeWidth: 3)),
                    ),
                  ),
                ),

                // Object name (respects setting)
                if (_showIcon &&
                    context.watch<AppState>().showWordsInLesson)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _lesson.objectName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Duo.textPrimary,
                      ),
                    ),
                  ),

                // ── CONTINUE BUTTON ──
                SlideTransition(
                  position: _continueSlide,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: ChunkyButton(
                      text: widget.lessonIndex < lessonData.length - 1
                          ? 'CONTINUE'
                          : 'START PRACTICE',
                      color: _showContinue ? Duo.green : Duo.disabled,
                      shadowColor: _showContinue
                          ? Duo.greenDark
                          : Duo.disabledDark,
                      onPressed:
                          _showContinue && !_showXPFlash ? _onContinue : null,
                      height: 56,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            // ── +XP FLASH OVERLAY ──
            if (_showXPFlash)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: ScaleTransition(
                      scale: _xpScale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 20),
                        decoration: BoxDecoration(
                          color: Duo.gold,
                          borderRadius: BorderRadius.circular(Duo.r20),
                          boxShadow: [
                            BoxShadow(
                              color: Duo.goldDark.withValues(alpha: 0.6),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: Duo.white, size: 34),
                            SizedBox(width: 10),
                            Text(
                              '+10 XP',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Duo.white,
                              ),
                            ),
                          ],
                        ),
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
