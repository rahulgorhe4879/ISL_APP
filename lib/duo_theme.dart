import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════
//  DUOLINGO DESIGN SYSTEM — COLORS
// ═══════════════════════════════════════════════════

class Duo {
  // Primary greens
  static const Color green = Color(0xFF58CC02);
  static const Color greenDark = Color(0xFF58A700);
  static const Color greenDarker = Color(0xFF4C8C00);
  static const Color greenLight = Color(0xFFD7FFB8);

  // Blues
  static const Color blue = Color(0xFF1CB0F6);
  static const Color blueDark = Color(0xFF1899D6);
  static const Color blueLight = Color(0xFFDDF4FF);

  // Reds
  static const Color red = Color(0xFFFF4B4B);
  static const Color redDark = Color(0xFFEA2B2B);
  static const Color redLight = Color(0xFFFFDFE0);

  // Yellows / Golds
  static const Color gold = Color(0xFFFFC800);
  static const Color goldDark = Color(0xFFE5B400);
  static const Color yellow = Color(0xFFFFC800);
  static const Color yellowLight = Color(0xFFFFF4CC);

  // Orange
  static const Color orange = Color(0xFFFF9600);
  static const Color orangeDark = Color(0xFFE58600);

  // Purple
  static const Color purple = Color(0xFFCE82FF);
  static const Color purpleDark = Color(0xFFB866E6);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFF7F7F0);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderDark = Color(0xFFCECECE);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFFAFAFAF);
  static const Color disabled = Color(0xFFE5E5E5);
  static const Color disabledDark = Color(0xFFCECECE);

  // Hearts
  static const Color heartRed = Color(0xFFFF4B4B);
  static const Color heartGrey = Color(0xFFE5E5E5);

  // Radii
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;

  // 3D button depth
  static const double depth = 4.0;
}

// ═══════════════════════════════════════════════════
//  CHUNKY 3D BUTTON — Core Duolingo interaction
// ═══════════════════════════════════════════════════

class ChunkyButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final double fontSize;

  const ChunkyButton({
    super.key,
    required this.text,
    this.icon,
    this.color = Duo.green,
    this.shadowColor = Duo.greenDark,
    this.textColor = Duo.white,
    this.onPressed,
    this.height = 56,
    this.width,
    this.fontSize = 17,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool off = widget.onPressed == null;
    final Color bg = off ? Duo.disabled : widget.color;
    final Color shadow = off ? Duo.disabledDark : widget.shadowColor;
    final Color txt = off ? Duo.textSecondary : widget.textColor;

    return GestureDetector(
      onTapDown: off ? null : (_) => setState(() => _pressed = true),
      onTapUp: off
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.mediumImpact();
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width ?? double.infinity,
        height: widget.height,
        transform: Matrix4.translationValues(0, _pressed ? Duo.depth : 0, 0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Duo.r16),
          boxShadow: _pressed
              ? []
              : [BoxShadow(color: shadow, offset: const Offset(0, Duo.depth))],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: txt, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: txt,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  CHUNKY PROGRESS BAR
// ═══════════════════════════════════════════════════

class ChunkyProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color bgColor;
  final double height;

  const ChunkyProgressBar({
    super.key,
    required this.value,
    this.color = Duo.green,
    this.bgColor = Duo.border,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionBox(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          widthFactor: value.clamp(0.02, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedFractionBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionBox> createState() =>
      _AnimatedFractionBoxState();
}

class _AnimatedFractionBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════════════
//  HEART ROW WITH SHAKE
// ═══════════════════════════════════════════════════

class HeartRow extends StatelessWidget {
  final int total;
  final int remaining;
  final int? shakingIndex;

  const HeartRow({
    super.key,
    required this.total,
    required this.remaining,
    this.shakingIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final alive = i < remaining;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ShakeWidget(
            shaking: shakingIndex == i,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                Icons.favorite,
                key: ValueKey('h_${i}_$alive'),
                color: alive ? Duo.heartRed : Duo.heartGrey,
                size: 28,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════
//  SHAKE WIDGET
// ═══════════════════════════════════════════════════

class ShakeWidget extends StatefulWidget {
  final bool shaking;
  final Widget child;
  const ShakeWidget({super.key, required this.shaking, required this.child});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.shaking && !old.shaking) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) =>
          Transform.translate(offset: Offset(_anim.value, 0), child: child),
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════════════
//  FEEDBACK BANNER — slides up from bottom
// ═══════════════════════════════════════════════════

class FeedbackBanner extends StatelessWidget {
  final bool visible;
  final bool isCorrect;
  final String buttonText;
  final VoidCallback onPressed;

  const FeedbackBanner({
    super.key,
    required this.visible,
    required this.isCorrect,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCorrect ? Duo.greenLight : Duo.redLight;
    final btn = isCorrect ? Duo.green : Duo.red;
    final btnS = isCorrect ? Duo.greenDark : Duo.redDark;
    final txt = isCorrect ? Duo.greenDarker : Duo.redDark;
    final ico = isCorrect ? Icons.check_circle : Icons.cancel;
    final lbl = isCorrect ? 'Correct!' : 'Incorrect';

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      bottom: visible ? 0 : -220,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(Duo.r20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(ico, color: txt, size: 28),
              const SizedBox(width: 10),
              Text(lbl,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: txt)),
            ]),
            const SizedBox(height: 16),
            ChunkyButton(
                text: buttonText, color: btn, shadowColor: btnS,
                onPressed: onPressed),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  GAME OVER OVERLAY
// ═══════════════════════════════════════════════════

class GameOverOverlay extends StatelessWidget {
  final bool visible;
  final VoidCallback onContinue;
  const GameOverOverlay(
      {super.key, required this.visible, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: visible
          ? Container(
              key: const ValueKey('go'),
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                            color: Duo.red, shape: BoxShape.circle),
                        child: const Icon(Icons.sentiment_dissatisfied,
                            color: Duo.white, size: 52),
                      ),
                      const SizedBox(height: 24),
                      const Text("Let's practice again!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Duo.white)),
                      const SizedBox(height: 8),
                      const Text(
                          'Watch the signs once more\nand try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.4)),
                      const SizedBox(height: 32),
                      ChunkyButton(
                          text: 'BACK TO LEARN',
                          icon: Icons.replay,
                          color: Duo.blue,
                          shadowColor: Duo.blueDark,
                          onPressed: onContinue),
                    ],
                  ),
                ),
              ))
          : const SizedBox.shrink(),
    );
  }
}

// ═══════════════════════════════════════════════════
//  LESSON TOP BAR  (X | progress bar | hearts)
// ═══════════════════════════════════════════════════

class LessonTopBar extends StatelessWidget {
  final double progress;
  final int? hearts;
  final int? totalHearts;
  final int? shakingHeart;
  final VoidCallback onClose;

  const LessonTopBar({
    super.key,
    required this.progress,
    this.hearts,
    this.totalHearts,
    this.shakingHeart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onClose();
            },
            icon: const Icon(Icons.close, color: Duo.textSecondary, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChunkyProgressBar(
              value: progress,
              color: Duo.green,
              height: 16,
            ),
          ),
          if (hearts != null && totalHearts != null) ...[
            const SizedBox(width: 12),
            HeartRow(
              total: totalHearts!,
              remaining: hearts!,
              shakingIndex: shakingHeart,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  STAT PILL — used in top bar (streak, gems, hearts)
// ═══════════════════════════════════════════════════

class StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;

  const StatPill({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Duo.border, width: 2),
        borderRadius: BorderRadius.circular(Duo.r12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Duo.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
