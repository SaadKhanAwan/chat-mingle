import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/screen/home_screen.dart';
import 'package:chat_mingle/screen/auth/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _disposed = false; // Add this flag

  @override
  void initState() {
    super.initState();
    // this is for aniamtion
    animateIt();
    Future.delayed(const Duration(seconds: 4), () {
      // Check if the widget is still mounted before navigating
      if (mounted) {
        if (APIs.auth.currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MyHomeScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  @override
  void dispose() {
    if (!_disposed) {
      _fadeAnimation.removeListener(_fadeListener);
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Chat-Mingle"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // this is beause scles inceares according to duration and images appers
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                "images/chat-box.png",
                width: mq.width * 0.5, // Set the initial size here
                height: mq.width * 0.5,
              ),
            ),
            const SizedBox(height: 20),
            // this is beause oppacity inceares according to duration and text appers
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                "Start your day with a smile😊!\n Welcome to Chat Mingle",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  animateIt() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward().then((value) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _fadeAnimation.addListener(_fadeListener);
            // Set a flag to indicate that the animation is completed
            _disposed = true;
            // Do not call dispose here
          }
        });
      });
    });
  }

  // Listener function for fade animation
  void _fadeListener() {
    if (_fadeAnimation.isCompleted) {
      // Do something when fade animation is completed
    }
  }
}
