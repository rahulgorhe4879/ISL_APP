import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'duo_theme.dart';
import 'lesson_complete_screen.dart';

// ═══════════════════════════════════════════════════
//  LEVEL 2 — PRACTICE  (Find embedded object in scene)
//  Watch sign video → tap the matching object in scene
// ═══════════════════════════════════════════════════

// Hitbox centres as fractions of the scene image's natural size.
// These align with objects embedded in scene1.png.
// Format: Offset(leftFraction, topFraction)
const List<Offset> _hitCentres = [
  Offset(0.58, 0.55), // Ball
  Offset(0.45, 0.45), // Car
  Offset(0.05, 0.60), // Boat
  Offset(0.75, 0.70), // Book
  Offset(0.78, 0.45), // Bag
];

// scene1.png native aspect ratio (width ÷ height).
// Adjust if the image dimensions differ.
const double _sceneAspect = 1462.0 / 974.0; // ≈ 1.5

const double _hitboxSize = 140.0; // generous tap target

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  static const int _totalHearts = 3;
  static const int _totalStages = 5;

  int _hearts = _totalHearts;
  int _currentStage = 0;
  bool _isSearching = false;
  int? _shakingHeart;

  bool? _lastTapCorrect; // null = not tapped yet
  Offset? _wrongTapPos;  // scene-fraction position of last wrong tap

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  bool _showGameOver = false;

  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;

  // Pulse animation for correct tap
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  LessonPageData get _stage =>
      practiceData[_currentStage.clamp(0, practiceData.length - 1)];

  @override
  void initState() {
    super.initState();

    _flashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _flashAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
    _flashCtrl.addStatusListener(
        (s) { if (s == AnimationStatus.completed) _flashCtrl.reverse(); });

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.4).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.elasticOut));

    _loadStage();
  }

  void _loadStage() {
    _videoCtrl?.dispose();
    setState(() {
      _videoReady = false;
      _isSearching = false;
      _lastTapCorrect = null;
      _wrongTapPos = null;
    });

    _videoCtrl = VideoPlayerController.asset(
      _stage.videoAsset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _videoCtrl!.setLooping(true);
        _videoCtrl!.setVolume(0);
        _videoCtrl!.play();
      });
  }

  void _enterSearch() {
    HapticFeedback.mediumImpact();
    _videoCtrl?.pause();
    setState(() => _isSearching = true);
  }

  void _onCorrectTap() {
    if (_lastTapCorrect != null || _showGameOver) return;
    HapticFeedback.heavyImpact();
    _pulseCtrl.forward(from: 0);
    setState(() {
      _lastTapCorrect = true;
      _wrongTapPos = null;
    });
  }

  void _onWrongTap(Offset sceneFraction) {
    if (_lastTapCorrect != null || _showGameOver) return;
    HapticFeedback.heavyImpact();
    _flashCtrl.forward(from: 0);

    final lostIndex = _hearts - 1;
    setState(() {
      _lastTapCorrect = false;
      _wrongTapPos = sceneFraction;
      _hearts--;
      _shakingHeart = lostIndex;
    });
    Future.delayed(const Duration(milliseconds: 500),
        () { if (mounted) setState(() => _shakingHeart = null); });
  }

  void _onContinue() {
    HapticFeedback.mediumImpact();
    if (_currentStage < _totalStages - 1) {
      setState(() => _currentStage++);
      _loadStage();
    } else {
      HapticFeedback.heavyImpact();
      final state = Provider.of<AppState>(context, listen: false);
      state.completePractice(perfect: _hearts == _totalHearts);
      state.completeNode(20);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) =>
              const LessonCompleteScreen(xpEarned: 20),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  void _onTryAgain() {
    HapticFeedback.lightImpact();
    setState(() {
      _lastTapCorrect = null;
      _wrongTapPos = null;
    });
    if (_hearts <= 0) {
      Future.delayed(const Duration(milliseconds: 200),
          () { if (mounted) setState(() => _showGameOver = true); });
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _flashCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStage + 1) / _totalStages;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Duo.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // ── TOP BAR ──
                LessonTopBar(
                  progress: progress,
                  hearts: _hearts,
                  totalHearts: _totalHearts,
                  shakingHeart: _shakingHeart,
                  onClose: () => Navigator.pop(context),
                ),

                Expanded(
                  child: _isSearching
                      ? _buildSearchView()
                      : _buildVideoPreview(),
                ),

                _buildBottomBar(bottomPad),
              ],
            ),

            // ── SCREEN RED FLASH (wrong tap) ──
            AnimatedBuilder(
              animation: _flashAnim,
              builder: (_, __) => IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Duo.red
                          .withValues(alpha: _flashAnim.value * 0.5),
                      width: _flashAnim.value * 8,
                    ),
                  ),
                ),
              ),
            ),

            // ── GAME OVER ──
            GameOverOverlay(
                visible: _showGameOver, onContinue: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  // ── VIDEO PREVIEW ──
  Widget _buildVideoPreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Watch the sign carefully',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Duo.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'Learn the sign for "${_stage.objectName}"',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Duo.textSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Duo.cardBg,
                borderRadius: BorderRadius.circular(Duo.r20),
                border: Border.all(color: Duo.border, width: 2.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: _videoReady && _videoCtrl != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Duo.r20 - 2),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoCtrl!.value.size.width,
                          height: _videoCtrl!.value.size.height,
                          child: VideoPlayer(_videoCtrl!),
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                          color: Duo.green, strokeWidth: 3)),
            ),
          ),
        ],
      ),
    );
  }

  // ── SCENE SEARCH VIEW ──
  Widget _buildSearchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hint row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Duo.white,
                  borderRadius: BorderRadius.circular(Duo.r12),
                  border: Border.all(color: Duo.green, width: 2.5),
                ),
                child: Image.asset(_stage.imageAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Text(
                'Find: ${_stage.objectName}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Duo.textPrimary),
              ),
            ],
          ),
        ),

        // Scene with hitboxes — full ratio image
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Duo.r20),
                border: Border.all(color: Duo.border, width: 2.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cw = constraints.maxWidth;
                  final ch = constraints.maxHeight;

                  // Calculate where the image actually renders within
                  // the container when using BoxFit.contain.
                  double imgW, imgH, offLeft, offTop;
                  if (cw / ch > _sceneAspect) {
                    // Container wider → letterbox left/right
                    imgH = ch;
                    imgW = ch * _sceneAspect;
                    offLeft = (cw - imgW) / 2;
                    offTop = 0;
                  } else {
                    // Container taller → letterbox top/bottom
                    imgW = cw;
                    imgH = cw / _sceneAspect;
                    offLeft = 0;
                    offTop = (ch - imgH) / 2;
                  }

                  final hit = _hitCentres[_currentStage];
                  final hitLeft = offLeft + hit.dx * imgW - _hitboxSize / 2;
                  final hitTop  = offTop  + hit.dy * imgH - _hitboxSize / 2;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background — wrong tap anywhere outside hitbox
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          // Convert tap to scene fraction for feedback dot
                          final lp = details.localPosition;
                          final fx = (lp.dx - offLeft) / imgW;
                          final fy = (lp.dy - offTop) / imgH;
                          _onWrongTap(Offset(fx, fy));
                        },
                        child: Image.asset(
                          'assets/images/scene1.png',
                          fit: BoxFit.contain,
                          width: cw,
                          height: ch,
                        ),
                      ),

                      // ── CORRECT HITBOX (invisible) ──
                      if (_lastTapCorrect == null)
                        Positioned(
                          left: hitLeft,
                          top: hitTop,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _onCorrectTap,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(
                                scale: _pulseCtrl.isAnimating
                                    ? _pulseAnim.value
                                    : 1.0,
                                child: child,
                              ),
                              child: const SizedBox(
                                width: _hitboxSize,
                                height: _hitboxSize,
                              ),
                            ),
                          ),
                        ),

                      // ── CORRECT GLOW (after correct tap) ──
                      if (_lastTapCorrect == true)
                        Positioned(
                          left: hitLeft,
                          top: hitTop,
                          child: Container(
                            width: _hitboxSize,
                            height: _hitboxSize,
                            decoration: BoxDecoration(
                              color: Duo.green.withValues(alpha: 0.25),
                              borderRadius:
                                  BorderRadius.circular(_hitboxSize / 2),
                              border: Border.all(
                                  color: Duo.green, width: 3.5),
                            ),
                            child: const Icon(Icons.check_circle,
                                color: Duo.green, size: 48),
                          ),
                        ),

                      // ── WRONG TAP INDICATOR ──
                      if (_wrongTapPos != null)
                        Positioned(
                          left: offLeft +
                              _wrongTapPos!.dx * imgW -
                              24,
                          top: offTop +
                              _wrongTapPos!.dy * imgH -
                              24,
                          child: IgnorePointer(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Duo.red.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Duo.red, width: 2.5),
                              ),
                              child: const Icon(Icons.close,
                                  color: Duo.red, size: 26),
                            ),
                          ),
                        ),

                      // ── PIP VIDEO (bottom-right) ──
                      if (_videoCtrl != null && _videoReady)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: 72,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Duo.r12),
                              border: Border.all(
                                  color: Duo.green, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoCtrl!.value.size.width,
                                height: _videoCtrl!.value.size.height,
                                child: VideoPlayer(_videoCtrl!),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── BOTTOM CTA BAR ──
  Widget _buildBottomBar(double bottomPad) {
    // Video preview → I'M READY
    if (!_isSearching) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
        decoration: const BoxDecoration(
          color: Duo.white,
          border:
              Border(top: BorderSide(color: Duo.border, width: 2)),
        ),
        child: ChunkyButton(
          text: "I'M READY!",
          icon: Icons.search,
          color: _videoReady ? Duo.blue : Duo.disabled,
          shadowColor:
              _videoReady ? Duo.blueDark : Duo.disabledDark,
          onPressed: _videoReady ? _enterSearch : null,
          height: 52,
          fontSize: 16,
        ),
      );
    }

    // Correct
    if (_lastTapCorrect == true) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
        decoration: const BoxDecoration(
          color: Duo.greenLight,
          border: Border(top: BorderSide(color: Duo.green, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Icon(Icons.check_circle,
                  color: Duo.greenDarker, size: 24),
              const SizedBox(width: 8),
              Text(
                'Great! Found the ${_stage.objectName}!',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Duo.greenDarker),
              ),
            ]),
            const SizedBox(height: 12),
            ChunkyButton(
              text: _currentStage < _totalStages - 1
                  ? 'CONTINUE'
                  : 'FINISH',
              color: Duo.green,
              shadowColor: Duo.greenDark,
              onPressed: _onContinue,
              height: 52,
              fontSize: 16,
            ),
          ],
        ),
      );
    }

    // Wrong
    if (_lastTapCorrect == false) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
        decoration: const BoxDecoration(
          color: Duo.redLight,
          border: Border(top: BorderSide(color: Duo.red, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(children: [
              Icon(Icons.cancel, color: Duo.redDark, size: 24),
              SizedBox(width: 8),
              Text(
                'Not quite — try again!',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Duo.redDark),
              ),
            ]),
            const SizedBox(height: 12),
            ChunkyButton(
              text: 'TRY AGAIN',
              color: Duo.red,
              shadowColor: Duo.redDark,
              onPressed: _onTryAgain,
              height: 52,
              fontSize: 16,
            ),
          ],
        ),
      );
    }

    // Searching, no tap yet
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
      decoration: const BoxDecoration(
        color: Duo.white,
        border: Border(top: BorderSide(color: Duo.border, width: 2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Duo.textSecondary, size: 22),
          const SizedBox(width: 10),
          Text(
            'Tap the ${_stage.objectName} in the image above',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Duo.textSecondary),
          ),
        ],
      ),
    );
  }
}
