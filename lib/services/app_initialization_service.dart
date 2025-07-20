import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AppInitializationService {
  static bool _hasCalledHealthCheck = false;
  static const String _healthCheckKey = 'health_check_called_session';

  /// Initialize the app - call health check only once per app session
  static Future<void> initialize() async {
    // Check if we've already called health check in this session
    if (_hasCalledHealthCheck) {
      print('Health check already called in this session, skipping...');
      return;
    }

    try {
      // Call health check to initialize backend (fire and forget)
      ApiServiceProvider.instance.healthCheck();
      
      // Mark as called for this session
      _hasCalledHealthCheck = true;
      
      // Optionally store in SharedPreferences for debugging
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_healthCheckKey, DateTime.now().toIso8601String());
      
      print('App initialization completed successfully');
    } catch (e) {
      print('App initialization failed (non-critical): $e');
      // Don't throw error - this is non-critical for app functionality
    }
  }

  /// Reset the health check flag (useful for testing or when app is completely restarted)
  static void reset() {
    _hasCalledHealthCheck = false;
  }

  /// Check if health check has been called in this session
  static bool get hasInitialized => _hasCalledHealthCheck;
}
