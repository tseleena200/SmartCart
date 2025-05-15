import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import 'package:onlinegroceries/view/login/sign_in_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          SizedBox(
            width: media.width,
            height: media.height,
            child: Image.asset(
              "assets/img/welcomescreen.jpeg",
              fit: BoxFit.cover,
              alignment: const Alignment(0.13, 0),
            ),
          ),

          // Dark Overlay
          Container(
            width: media.width,
            height: media.height,
            color: Colors.black.withOpacity(0.45),
          ),

          // Main Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // App Logo
                Image.asset(
                  "assets/img/app_logo.png",
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 16),

                // Welcome Text
                const Text(
                  "Welcome to\nSmartCart",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  "Scan. Shop. Go.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 32),

                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: RoundButton(
                    title: "Get Started",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInView(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 46),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
