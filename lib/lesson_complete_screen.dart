import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'duo_theme.dart';

// ═══════════════════════════════════════════════════
//  LESSON COMPLETE — Celebration screen
// ═══════════════════════════════════════════════════

class LessonCompleteScreen extends StatefulWidget {
  final int xpEarned;
  const LessonCompleteScreen({super.key, required this.xpEarned});

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late Animation<double> _starScale;

  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // Star bounce animation
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _starScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut));

    // Content fade + slide
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    // Sequence: star first, then content
    _starCtrl.forward();
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Duo.gold,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ── STAR ──
            ScaleTransition(
              scale: _starScale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Duo.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Duo.white,
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── TEXT & STATS ──
            SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentFade,
                child: Column(
                  children: [
                    const Text(
                      'Lesson Complete!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Duo.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // XP stat card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Duo.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Duo.r16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.bolt, color: Duo.white, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'TOTAL XP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '+${widget.xpEarned}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Duo.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Amazing badge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Duo.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Duo.r16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    color: Duo.white, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'AMAZING',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.check_circle,
                                color: Duo.white, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),

            // ── CONTINUE BUTTON ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: ChunkyButton(
                text: 'CONTINUE',
                color: Duo.white,
                shadowColor: Duo.goldDark,
                textColor: Duo.gold,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context); // back to home
                },
                height: 56,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
