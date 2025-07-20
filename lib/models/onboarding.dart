class OnboardingPageModel {
  final String title;
  final String description;
  final String imagePath;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  static List<OnboardingPageModel> getOnboardingPages() {
    return [
      OnboardingPageModel(
        title: "Welcome to Mugeshbabu",
        description: "One app for all your cable, internet, and utility services.",
        imagePath: "assets/images/onboarding_1.png",
      ),
      OnboardingPageModel(
        title: "Manage Your Services",
        description: "Track your subscriptions, plans, and due payments with ease.",
        imagePath: "assets/images/onboarding_2.png",
      ),
      OnboardingPageModel(
        title: "Quick Bill Payments",
        description: "Recharge and pay your bills instantly and securely.",
        imagePath: "assets/images/onboarding_3.png",
      ),
    ];
  }
}
