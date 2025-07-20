# Mugeshbabu - Multi-Service Platform

A comprehensive cross-platform mobile application built with Flutter that serves as a multi-service platform for managing Cable TV, Internet plans, utility bill payments, and customer support.

## 🚀 Features

### 📱 Core Services
- **Cable TV Management**: View current plans, recharge packages, and manage subscriptions
- **Internet Plans**: Monitor data usage, renew plans, and check service status
- **Bill Payments**: Pay utility bills (Electricity, Water, Gas, etc.) with secure transactions
- **Support System**: Raise tickets, track complaints, and get customer support

### 🎨 User Experience
- **Modern UI**: Clean, responsive design with Material Design 3
- **Dark Mode**: Full dark theme support
- **Cross-Platform**: Works seamlessly on both Android and iOS
- **Offline Support**: Basic functionality available without internet
- **Real-time Updates**: Live status updates and notifications

### 🔐 Authentication
- **OTP Login**: Secure phone number-based authentication
- **Session Management**: Persistent login sessions
- **Profile Management**: Edit personal information and preferences

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core configurations
│   ├── theme.dart           # App themes (light/dark)
│   ├── constants.dart       # App constants and configurations
│   └── router.dart          # Navigation routing
├── screens/                 # All app screens
│   ├── login_screen.dart    # Authentication screen
│   ├── home_screen.dart     # Dashboard/home screen
│   ├── cable_tv_screen.dart # Cable TV management
│   ├── internet_screen.dart # Internet plan management
│   ├── bill_payment_screen.dart # Bill payment interface
│   ├── support_screen.dart  # Customer support
│   └── profile_screen.dart  # User profile management
├── widgets/                 # Reusable UI components
│   ├── service_card.dart    # Service selection cards
│   └── quick_action_tile.dart # Quick action tiles
└── services/               # API and business logic (future)
```

## 🛠️ Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **flutter_riverpod**: State management solution
- **go_router**: Declarative routing
- **Material Design 3**: Modern UI components

### 📦 Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  go_router: ^13.0.0            # Navigation
  http: ^1.2.0                  # HTTP requests
  firebase_auth: ^4.17.8        # Authentication (optional)
  shared_preferences: ^2.2.2    # Local storage
  image_picker: ^1.0.5          # Image selection
  file_picker: ^6.2.0           # File selection
  fluttertoast: ^8.2.5          # Toast notifications
  lottie: ^3.0.0                # Animations
  connectivity_plus: ^5.0.2     # Network connectivity
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.2.6)
- Dart SDK
- Android Studio / VS Code
- Android/iOS development setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mugeshbabu_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## 📱 App Flow

### Authentication Flow
1. **Login Screen**: Enter phone number
2. **OTP Verification**: Verify with 4-digit OTP
3. **Home Dashboard**: Access all services

### Service Management
1. **Cable TV**: View current plan → Select package → Recharge
2. **Internet**: Check usage → Choose plan → Renew
3. **Bills**: Select bill type → Enter details → Pay
4. **Support**: Choose category → Describe issue → Submit ticket

## 🎨 UI/UX Features

### Design Principles
- **Material Design 3**: Modern, accessible interface
- **Responsive Layout**: Adapts to different screen sizes
- **Consistent Theming**: Unified color scheme and typography
- **Intuitive Navigation**: Easy-to-use navigation patterns

### Accessibility
- **High Contrast**: Readable text and UI elements
- **Touch Targets**: Appropriately sized interactive elements
- **Screen Reader Support**: Semantic markup for accessibility

## 🔧 Configuration

### Theme Customization
Edit `lib/core/theme.dart` to customize:
- Primary and secondary colors
- Typography styles
- Component themes
- Dark/light mode variations

### Constants Management
Update `lib/core/constants.dart` for:
- API endpoints
- Service packages
- UI constants
- App configurations

## 🚀 Future Enhancements

### Planned Features
- [ ] Real API integration
- [ ] Push notifications
- [ ] Biometric authentication
- [ ] Payment gateway integration
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Offline data synchronization

### Technical Improvements
- [ ] State management optimization
- [ ] Performance monitoring
- [ ] Automated testing suite
- [ ] CI/CD pipeline
- [ ] Code documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and queries:
- **Email**: support@mugeshbabu.com
- **Phone**: +91 98765 43210
- **Hours**: 24/7 Support Available

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Open source community for various packages used

---

**Built with ❤️ using Flutter**
