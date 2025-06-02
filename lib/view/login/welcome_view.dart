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
  final PageController _pageController = PageController();
  int currentPage = 0;


  final List<String> welcomeImages = [
    "assets/img/welcomescreen1.png", // First
    "assets/img/welcomescreen3.png", // Second
    "assets/img/welcomescreen2.png", // Third
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1D4DA),
      body: Stack(
        children: [
          // PageView for welcome slides
          PageView.builder(
            controller: _pageController,
            itemCount: welcomeImages.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  SizedBox(
                    width: media.width,
                    height: media.height,
                    child: Image.asset(
                      welcomeImages[index],
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                  Container(
                    width: media.width,
                    height: media.height,
                    color: Colors.black.withOpacity(0.45),
                  ),
                ],
              );
            },
          ),

          // Dots indicator
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(welcomeImages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 12 : 8,
                  height: currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),

          // "Get Started" button on last screen
          if (currentPage == welcomeImages.length - 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 25),
                color: Colors.transparent,
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
            ),
        ],
      ),
    );
  }
}
