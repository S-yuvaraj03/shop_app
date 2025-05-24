import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:shop_app/screens/authenticate_screen.dart';

import '../utils/constant/sizes.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Widget> _buildPageContent() {
    return [
      _buildPage(
        image: 'assets/images/gshoppingad5.jpg',
        title: "Choose Products",
        description:
            "Browse our selection of products and choose the ones you like",
      ),
      _buildPage(
        image: 'assets/images/gshoppingad3.jpg',
        title: "Make Payment",
        description:
            "Securely complete your payment to finalize your order",
      ),
      _buildPage(
        image: 'assets/images/gshoppingad4.jpg',
        title: "Get Your Order",
        description:
            "Expect prompt delivery of your chosen items.",
      ),
    ];
  }

  Widget _buildPage({required String image, required String title, required String description}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/googlelogo.png",
                    height: 100,
                    width: 120,
                  ),
                  Text(
                    'Shopping',
                    style: TextStyle(color: Colors.grey, fontSize: TSizes.Lg),
                  ),
                ],
              ),         
            ],
          ),
        ),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.all(28.0),
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        SizedBox(height: 30.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Returning false prevents the app from going back.
        return false;
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: _buildPageContent(),
              ),
              Positioned(
                bottom: 20.0,
                left: 20.0,
                right: 20.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage != 0
                        ? TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text("Prev"),
                          )
                        : SizedBox.shrink(),
                    Row(
                      children: List.generate(
                        _buildPageContent().length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                          height: 8.0,
                          width: _currentPage == index ? 24.0 : 8.0,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.black
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_currentPage == _buildPageContent().length - 1) {
                          // Mark onboarding as complete
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('onboardingComplete', true);
                          
                          // Navigate to landing page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AuthenticateScreen()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _buildPageContent().length - 1
                            ? "Get Started"
                            : "Next",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
