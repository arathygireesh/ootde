import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      final Widget targetScreen = const WelcomeScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext meContext) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Elegant decorative subtle background circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3E8FF).withValues(alpha: 0.6),
              ),
            ),
          ).animate().scale(duration: 1200.ms, curve: Curves.easeOut),

          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFAF5FF),
              ),
            ),
          ).animate().scale(duration: 1500.ms, curve: Curves.easeOut),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Image with Scale + Pulse
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 8,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeIn)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 1000.ms,
                      curve: Curves.elasticOut,
                    )
                    .shimmer(delay: 1200.ms, duration: 1500.ms, color: const Color(0xFFD8B4FE)),

                const SizedBox(height: 28),

                // Animated App Title "OOTDee"
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'OOTD',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: const Color(0xFF6B21A8),
                        ),
                      ),
                      TextSpan(
                        text: 'ee',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: const Color(0xFF9333EA),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 800.ms)
                    .slideY(begin: 0.4, end: 0, duration: 800.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 12),

                // Tagline with Fade In
                Text(
                  'Your AI Smart Wardrobe & Outfit Stylist',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7E22CE).withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 800.ms)
                    .slideY(begin: 0.3, end: 0, duration: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
