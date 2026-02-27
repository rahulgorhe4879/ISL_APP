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

const List<Offset> _hitCentres = [
  Offset(0.63, 0.72), // Ball
  Offset(0.45, 0.60), // Car
  Offset(0.02, 0.75), // Boat
  Offset(1.15, 0.96), // Book
  Offset(0.88, 0.70), // Bag
];

const double _sceneAspect = 1462.0 / 974.0;
const double _hitboxSize = 140.0;

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

  bool? _lastTapCorrect;
  Offset? _wrongTapPos;

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _showGameOver = false;

  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Tutorial logic
  late AnimationController _tutorialCtrl;
  late Animation<Offset> _handPosAnim;
  bool _isTutorialActive = false;
  bool _tutorialShown = false;

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

    // Initialize Tutorial Animation (Scanning pattern)
    _tutorialCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));
    
    final targetHit = _hitCentres[0];
    _handPosAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.2, 0.2), end: const Offset(0.8, 0.3)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.8, 0.3), end: const Offset(0.2, 0.6)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.2, 0.6), end: const Offset(0.8, 0.8)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.8, 0.8), end: targetHit).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_tutorialCtrl);

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

    // Trigger tutorial only on first stage search, once per screen session
    if (_currentStage == 0 && !_tutorialShown) {
      setState(() {
        _isTutorialActive = true;
        _tutorialShown = true;
      });
      _tutorialCtrl.forward(from: 0);
    }
  }

  void _returnToVideo() {
    HapticFeedback.lightImpact();
    _videoCtrl?.play();
    setState(() => _isSearching = false);
  }

  void _onCorrectTap() {
    if (_lastTapCorrect != null || _showGameOver) return;
    
    if (_isTutorialActive) {
      setState(() => _isTutorialActive = false);
      _tutorialCtrl.stop();
    }

    // Stronger sensory feedback: double vibration to simulate a longer (~0.2s) pulse
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.vibrate());

    _pulseCtrl.forward(from: 0);
    setState(() {
      _lastTapCorrect = true;
      _wrongTapPos = null;
    });
  }

  void _onWrongTap(Offset sceneFraction) {
    if (_lastTapCorrect != null || _showGameOver) return;

    if (_isTutorialActive) {
      setState(() => _isTutorialActive = false);
      _tutorialCtrl.stop();
    }

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
    _tutorialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStage + 1) / _totalStages;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _isSearching ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
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

            AnimatedBuilder(
              animation: _flashAnim,
              builder: (_, __) => IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Duo.red.withValues(alpha: _flashAnim.value * 0.5),
                      width: _flashAnim.value * 8,
                    ),
                  ),
                ),
              ),
            ),

            GameOverOverlay(
                visible: _showGameOver, onContinue: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Duo.r20),
                border: Border.all(color: isDark ? Colors.white12 : Duo.border, width: 2.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: _videoReady && _videoCtrl != null
                  ? Stack(
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: _videoCtrl!.value.size.width,
                        height: _videoCtrl!.value.size.height,
                        child: VideoPlayer(_videoCtrl!),
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
        ],
      ),
    );
  }

  Widget _buildSearchView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cw = constraints.maxWidth;
        final ch = constraints.maxHeight;

        double imgW, imgH, offLeft, offTop;
        if (cw / ch > _sceneAspect) {
          imgH = ch; imgW = ch * _sceneAspect;
          offLeft = (cw - imgW) / 2; offTop = 0;
        } else {
          imgW = cw; imgH = cw / _sceneAspect;
          offLeft = 0; offTop = (ch - imgH) / 2;
        }

        final hit = _hitCentres[_currentStage];
        final hitLeft = offLeft + hit.dx * imgW - _hitboxSize / 2;
        final hitTop  = offTop  + hit.dy * imgH - _hitboxSize / 2;

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final lp = details.localPosition;
                final fx = (lp.dx - offLeft) / imgW;
                final fy = (lp.dy - offTop) / imgH;
                _onWrongTap(Offset(fx, fy));
              },
              child: Image.asset(
                'assets/images/scene1.png',
                fit: BoxFit.cover,
              ),
            ),

            if (_lastTapCorrect == null)
              Positioned(
                left: hitLeft, top: hitTop,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onCorrectTap,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseCtrl.isAnimating ? _pulseAnim.value : 1.0,
                      child: child,
                    ),
                    child: const SizedBox(width: _hitboxSize, height: _hitboxSize),
                  ),
                ),
              ),

            if (_lastTapCorrect == true)
              Positioned(
                left: hitLeft, top: hitTop,
                child: Container(
                  width: _hitboxSize, height: _hitboxSize,
                  decoration: BoxDecoration(
                    color: Duo.green.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(_hitboxSize / 2),
                    border: Border.all(color: Duo.green, width: 3.5),
                  ),
                  child: const Icon(Icons.check_circle, color: Duo.green, size: 48),
                ),
              ),

            if (_wrongTapPos != null)
              Positioned(
                left: offLeft + _wrongTapPos!.dx * imgW - 24,
                top: offTop + _wrongTapPos!.dy * imgH - 24,
                child: IgnorePointer(
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Duo.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Duo.red, width: 2.5),
                    ),
                    child: const Icon(Icons.close, color: Duo.red, size: 26),
                  ),
                ),
              ),

            if (_isTutorialActive)
              AnimatedBuilder(
                animation: _handPosAnim,
                builder: (context, child) {
                  final pos = _handPosAnim.value;
                  return Positioned(
                    left: offLeft + pos.dx * imgW - 15,
                    top: offTop + pos.dy * imgH - 5,
                    child: IgnorePointer(
                      child: Icon(
                        Icons.touch_app,
                        size: 60,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 15,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            if (_videoCtrl != null && _videoReady)
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: _returnToVideo,
                  child: Container(
                    width: 72, height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Duo.r12),
                      border: Border.all(color: Duo.green, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8, offset: const Offset(0, 4),
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
              ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(double bottomPad) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isSearching) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: isDark ? Colors.white10 : Duo.border, width: 2)),
        ),
        child: ChunkyButton(
          text: "",
          icon: Icons.search_rounded,
          color: _videoReady ? Duo.blue : (isDark ? const Color(0xFF2E3E44) : Duo.disabled),
          shadowColor: _videoReady ? Duo.blueDark : (isDark ? const Color(0xFF1F2E35) : Duo.disabledDark),
          onPressed: _videoReady ? _enterSearch : null,
          height: 60,
          fontSize: 16,
        ),
      );
    }

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
            const Icon(Icons.check_circle, color: Duo.greenDarker, size: 48),
            const SizedBox(height: 12),
            ChunkyButton(
              text: "",
              icon: _currentStage < _totalStages - 1 ? Icons.arrow_forward : Icons.celebration,
              color: Duo.green, shadowColor: Duo.greenDark,
              onPressed: _onContinue, height: 60, fontSize: 16,
            ),
          ],
        ),
      );
    }

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
            const Icon(Icons.cancel, color: Duo.redDark, size: 48),
            const SizedBox(height: 12),
            ChunkyButton(
              text: "",
              icon: Icons.refresh,
              color: Duo.red, shadowColor: Duo.redDark,
              onPressed: _onTryAgain, height: 60, fontSize: 16,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).scaffoldBackgroundColor : Duo.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Duo.border, width: 2)),
      ),
      child: const SizedBox(height: 24),
    );
  }
}
