class AppConstants {
  // App Info
  static const String appName = 'Mugeshbabu';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (Mock for now)
  static const String baseUrl = 'https://api.mugeshbabu.com';
  static const String loginEndpoint = '/auth/login';
  static const String otpEndpoint = '/auth/verify-otp';
  static const String cableTvEndpoint = '/services/cable-tv';
  static const String internetEndpoint = '/services/internet';
  static const String billsEndpoint = '/services/bills';
  static const String supportEndpoint = '/support';
  
  // SharedPreferences Keys
  static const String isLoggedInKey = 'is_logged_in';
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Service Types
  static const List<String> billTypes = [
    'Electricity',
    'Water',
    'Gas',
    'Telephone',
    'Internet',
    'Cable TV',
  ];
  
  // Support Categories
  static const List<String> supportCategories = [
    'Technical Issue',
    'Billing Query',
    'Service Request',
    'Complaint',
    'General Inquiry',
  ];
  
  // Cable TV Packages
  static const List<Map<String, dynamic>> cableTvPackages = [
    {
      'name': 'Basic Package',
      'price': 299,
      'channels': 150,
      'validity': 30,
      'description': 'Essential channels for daily entertainment'
    },
    {
      'name': 'Premium Package',
      'price': 599,
      'channels': 300,
      'validity': 30,
      'description': 'All channels including premium content'
    },
    {
      'name': 'Sports Package',
      'price': 399,
      'channels': 200,
      'validity': 30,
      'description': 'Sports channels with entertainment'
    },
  ];
  
  // Internet Plans
  static const List<Map<String, dynamic>> internetPlans = [
    {
      'name': 'Basic Plan',
      'speed': '50 Mbps',
      'data': '500 GB',
      'price': 699,
      'validity': 30,
      'description': 'Perfect for basic browsing and streaming'
    },
    {
      'name': 'Premium Plan',
      'speed': '100 Mbps',
      'data': 'Unlimited',
      'price': 1299,
      'validity': 30,
      'description': 'High-speed unlimited internet'
    },
    {
      'name': 'Ultra Plan',
      'speed': '200 Mbps',
      'data': 'Unlimited',
      'price': 1999,
      'validity': 30,
      'description': 'Ultra-fast speed for heavy usage'
    },
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
}
