import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth/login_screen.dart';
import 'auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _animate = false;

  // Controller for Heartbeat Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Heartbeat Animation Setup (Lub-Dub effect)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    startAppFlow();
  }

  Future<void> startAppFlow() async {
    // 2. Logo Animation Trigger
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _animate = true);

    // 3. Navigate to Login after 4 seconds
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 BACKGROUND: Teal Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF009688), // Teal
                  Color(0xFF4DB6AC), // Lighter Teal
                ],
              ),
            ),
          ),

          // 🎬 MAIN LOGO (Center)
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _animate ? 1.0 : 0.0,
              curve: Curves.easeIn,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutBack,
                width: _animate ? 200 : 100,
                height: _animate ? 200 : 100,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_hospital_rounded,
                        size: 60,
                        color: Color(0xFF009688),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "MediCare",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ❤️ NEW LOADING ANIMATION (Heartbeat at Bottom)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Pulsing Heart Icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: const Icon(
                    Icons.monitor_heart_outlined, // ECG Icon
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),

                // Professional Loading Text
                const Text(
                  "Setting up your clinic...",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
