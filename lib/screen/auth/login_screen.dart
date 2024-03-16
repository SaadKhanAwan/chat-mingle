import 'dart:io';

import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/widgets/snapbar.dart';
import 'package:chat_mingle/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // this is use for animation
    animateIt();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  handleLoginServices() {
    Dailogues.getProgrssindecator(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if ((await APIs.userExist())) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MyHomeScreen(),
            ),
          );
          Dailogues.getSnacBar(context, "Login successfully");
        } else {
          await APIs.createuser().then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MyHomeScreen(),
              ),
            );
            Dailogues.getSnacBar(context, "Login successfully");
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // for responsive ui
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Chat-Mingle"),
      ),
      body: Stack(
        children: [
          Positioned(
            left: mq.width * .25,
            top: mq.height * .15,
            width: mq.width * .5,
            // here slider is use because icon slides from left to right
            child: SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                "images/chat-box.png",
              ),
            ),
          ),
          Positioned(
            top: mq.height * .65,
            left: mq.width * .05,
            height: mq.height * .10,
            width: mq.width * .9,
            child: ElevatedButton.icon(
              onPressed: () {
                handleLoginServices();
              },
              label: const Text(
                "Sign in with Google",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: Image.asset(
                "images/google.png",
                height: mq.height * .05,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.purple.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  animateIt() {
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Create a slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Offscreen to the right
      end: const Offset(0.0, 0.0), // Center of the screen
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation when the screen opens
    _animationController.forward();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // for internet connection
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      Dailogues.getSnacBar(context, "Check your internet connection");
      return null;
    }
  }
}
