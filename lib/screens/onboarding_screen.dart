import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/onboarding.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPageModel> _pages = OnboardingPageModel.getOnboardingPages();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as seen and navigate to login page
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _skipToLogin() async {
    // Mark onboarding as seen and navigate to login page
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipToLogin,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            child: Image.asset(
                              page.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback when image is not found
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    _getIconForPage(index),
                                    size: 120,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Content
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Title
                              Text(
                                page.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),

                              // Description
                              Text(
                                page.description,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section with indicator and button
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      spacing: 16,
                      activeDotColor: Theme.of(context).primaryColor,
                      dotColor: Colors.grey[300]!,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Additional info for last page
                  if (_currentPage == _pages.length - 1)
                    Text(
                      'Join thousands of satisfied customers',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.dashboard_outlined;
      case 2:
        return Icons.payment_outlined;
      default:
        return Icons.apps_outlined;
    }
  }
}
