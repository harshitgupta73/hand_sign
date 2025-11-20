import 'package:classify/screens/HomeScreen.dart';
import 'package:flutter/material.dArt';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = (index == 2);
              });
            },
            children: [
              // --- Page 1 ---
              OnboardingPage(
                title: "Welcome to SignDetect",
                description:
                "A real-time hand sign language detector powered by AI.",
                imagePath: "assets/images/hand_img_3.png",
              ),

              // --- Page 2 ---
              OnboardingPage(
                title: "How It Works",
                description:
                "Simply point your front camera at your hand. The app will detect the sign and speak the result.",
                imagePath: "assets/images/hand_img_2.png",
              ),

              // --- Page 3 ---
              OnboardingPage(
                title: "Privacy First",
                description:
                "All processing happens on your device. Your camera feed never leaves your phone.",
                imagePath: "assets/images/hand_img_1.png",
              ),
            ],
          ),

          // --- Bottom Controls (Dots and Button) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Row(
                children: [
                  // --- Skip Button
                  _isLastPage
                      ? Spacer()
                      : TextButton(
                    child: Text("SKIP"),
                    onPressed: _completeOnboarding,
                  ),

                  Spacer(),

                  // --- Page Indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Theme.of(context).primaryColor,
                      dotColor: Colors.grey.shade300,
                    ),
                  ),

                  Spacer(),

                  // --- Next / Get Started Button
                  _isLastPage
                      ? FilledButton(
                    child: Text("Get Started"),
                    onPressed: _completeOnboarding,
                  )
                      : IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widget with the new "Title -> Description -> Image" layout ---
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- TITLE ---
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // --- DESCRIPTION ---
          Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60), // Space between text and image

          // --- IMAGE ---
          Image.asset(
            imagePath,
            height: 250, // Adjust height as needed
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}