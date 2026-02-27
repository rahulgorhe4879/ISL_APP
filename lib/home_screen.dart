import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'duo_theme.dart';
import 'learn_screen.dart';
import 'practice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _TopStatsBar(state: state),
                _UnitHeader(state: state),
                Expanded(child: _LearningPath(state: state)),
                _StickyCtaButton(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopStatsBar extends StatelessWidget {
  final AppState state;
  const _TopStatsBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final int hearts = (state.totalXP ~/ 10).clamp(0, 3);
    final bool heartsEmpty = hearts == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Duo.r16),
        border: isDark ? Border.all(color: Colors.white10, width: 1.5) : null,
        boxShadow: isDark ? null : const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _StreakPill(streak: state.streak),
          const Spacer(),
          _StatChip(
            icon: Icons.diamond_rounded,
            iconColor: Duo.blue,
            value: '${state.gems}',
          ),
          const SizedBox(width: 10),
          _StatChip(
            icon: Icons.favorite_rounded,
            iconColor: Duo.heartRed,
            value: '$hearts',
            urgent: heartsEmpty,
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int streak;
  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    final bool active = streak > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? Duo.orange.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Duo.r12),
        border: Border.all(
          color: active
              ? Duo.orange.withValues(alpha: 0.45)
              : (isDark ? Colors.white24 : Duo.border),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: active ? Duo.orange : Duo.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: active ? Duo.orange : Duo.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final bool urgent;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: urgent ? Duo.red.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(Duo.r12),
        border: Border.all(
          color: urgent ? Duo.red.withValues(alpha: 0.45) : (isDark ? Colors.white24 : Duo.border),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: urgent ? Duo.red : iconColor, size: 20),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: urgent ? Duo.red : (isDark ? Colors.white : Duo.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitHeader extends StatelessWidget {
  final AppState state;
  const _UnitHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    const int totalLessons = 7;
    final int completedLessons = state.lessonsCompleted.clamp(0, totalLessons);
    final double progress = completedLessons / totalLessons;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5ED418), Color(0xFF46A800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Duo.r20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3558CC02),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIT 1',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Duo.white.withValues(alpha: 0.75),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Sign Language Basics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Duo.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Duo.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(Duo.r12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Duo.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Duo.white.withValues(alpha: 0.28),
              valueColor: const AlwaysStoppedAnimation<Color>(Duo.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$completedLessons of $totalLessons lessons complete',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Duo.white.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyCtaButton extends StatelessWidget {
  final AppState state;
  const _StickyCtaButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final int i = state.currentNodeIndex;
    if (i >= pathNodes.length) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final node = pathNodes[i];
    final String label = node.type == PathNodeType.practice
        ? 'Start Practice'
        : node.type == PathNodeType.checkpoint
        ? 'Start Review'
        : 'Continue Lesson';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: isDark ? const Border(top: BorderSide(color: Colors.white10, width: 2)) : null,
        boxShadow: isDark ? null : const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 16,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: ChunkyButton(
        text: label,
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _navigateToNode(context, i, state),
      ),
    );
  }
}

void _navigateToNode(BuildContext context, int index, AppState state) {
  if (!state.isNodeUnlocked(index)) {
    HapticFeedback.lightImpact();
    return;
  }

  HapticFeedback.mediumImpact();
  final node = pathNodes[index];

  if (node.type == PathNodeType.checkpoint) {
    if (state.isNodeActive(index)) state.completeNode(5);
    return;
  }

  final Widget screen = node.type == PathNodeType.practice
      ? const PracticeScreen()
      : LearnScreen(lessonIndex: index);

  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
    ),
  );
}

class _LearningPath extends StatelessWidget {
  final AppState state;
  const _LearningPath({required this.state});

  static const double _nodeSpacing = 130.0;
  static const double _circleDiameter = 64.0;
  static const double _slotSize = 96.0;
  static const double _topPadding = 40.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalHeight =
        _topPadding + (pathNodes.length * _nodeSpacing) + 80;

    final List<Offset> positions = [];
    for (int i = 0; i < pathNodes.length; i++) {
      final x = pathNodes[i].xPercent * (screenWidth - _circleDiameter) +
          (_circleDiameter / 2);
      final y = _topPadding + (i * _nodeSpacing) + (_circleDiameter / 2);
      positions.add(Offset(x, y));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(screenWidth, totalHeight),
              painter: _PathLinePainter(
                positions: positions,
                completedUpTo: state.currentNodeIndex,
              ),
            ),

            for (int i = 0; i < pathNodes.length; i++)
              Positioned(
                left: positions[i].dx - (_slotSize / 2),
                top: positions[i].dy - (_slotSize / 2),
                child: _PathNodeWidget(
                  index: i,
                  data: pathNodes[i],
                  isCompleted: state.isNodeCompleted(i),
                  isActive: state.isNodeActive(i),
                  isLocked: !state.isNodeUnlocked(i),
                  onTap: () => _navigateToNode(context, i, state),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PathLinePainter extends CustomPainter {
  final List<Offset> positions;
  final int completedUpTo;

  _PathLinePainter({required this.positions, required this.completedUpTo});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    for (int i = 0; i < positions.length - 1; i++) {
      final start = positions[i];
      final end = positions[i + 1];
      final midY = (start.dy + end.dy) / 2;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx, midY, end.dx, midY, end.dx, end.dy);

      if (i < completedUpTo) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Duo.green
            ..strokeWidth = 7
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      } else {
        _drawDashed(
          canvas,
          path,
          Paint()
            ..color = const Color(0xFFD4D4D4)
            ..strokeWidth = 6
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const double dashLen = 11.0;
    const double gapLen = 7.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final segEnd = (d + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, segEnd), paint);
        d += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_PathLinePainter old) =>
      old.completedUpTo != completedUpTo;
}

class _PathNodeWidget extends StatefulWidget {
  final int index;
  final PathNodeData data;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const _PathNodeWidget({
    required this.index,
    required this.data,
    required this.isCompleted,
    required this.isActive,
    required this.isLocked,
    required this.onTap,
  });

  @override
  State<_PathNodeWidget> createState() => _PathNodeWidgetState();
}

class _PathNodeWidgetState extends State<_PathNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isActive) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PathNodeWidget old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isActive && old.isActive) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 64.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor;
    final Color shadowColor;
    final Color iconColor;
    final IconData icon;

    if (widget.isCompleted) {
      bgColor = Duo.gold;
      shadowColor = Duo.goldDark;
      iconColor = Duo.white;
      icon = widget.data.type == PathNodeType.checkpoint
          ? Icons.star_rounded
          : Icons.check_rounded;
    } else if (widget.isActive) {
      bgColor = Duo.green;
      shadowColor = Duo.greenDark;
      iconColor = Duo.white;
      icon = widget.data.icon;
    } else {
      bgColor = isDark ? const Color(0xFF2E3E44) : const Color(0xFFE8E8E8);
      shadowColor = isDark ? const Color(0xFF1F2E35) : const Color(0xFFC8C8C8);
      iconColor = isDark ? Colors.white24 : const Color(0xFFB0B0B0);
      icon = widget.data.icon;
    }

    Widget circle = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: shadowColor, offset: const Offset(0, 5)),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );

    if (widget.isLocked) {
      circle = Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            bottom: -3,
            right: -3,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4B5D65) : const Color(0xFF9E9E9E),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.5),
              ),
              child: const Icon(Icons.lock_rounded, size: 11, color: Duo.white),
            ),
          ),
        ],
      );
    }

    if (widget.isActive) {
      circle = AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size + 30,
                height: size + 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Duo.green.withValues(alpha: 0.18),
                ),
              ),
              Container(
                width: size + 12,
                height: size + 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.white30 : Duo.white, width: 3.5),
                ),
              ),
              child!,
            ],
          ),
        ),
        child: circle,
      );
    }

    return SizedBox(
      width: size + 32,
      height: size + 32,
      child: Center(child: circle),
    );
  }
}
