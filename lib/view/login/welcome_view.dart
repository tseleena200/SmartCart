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
    // TODO: implement initState
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
          Image.asset(
            "assets/img/welcomescreen.jpeg",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
            alignment: Alignment(0.13, 0),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/img/app_logo.png",
                  width: 60,
                  height: 60,
                ),
                const SizedBox(
                  height: 8,
                ), //space
                //First Row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "   Welcome\n to SmartCart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                //Second Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Scan. Shop. Go.",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF).withAlpha(500),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ), //space
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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

                const SizedBox(
                  height: 46,
                ), //space between the text and buttons
              ],
            ),
          ),
        ],
      ),
    );
  }
}
