import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/service.dart';
import '../models/auth.dart';

enum Environment { development, production }

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException() : super('Request timeout. Please try again.');
}

class ServerException extends ApiException {
  ServerException(String message, int statusCode) 
      : super(message, statusCode: statusCode);
}

class ApiService {
  static const String _prodBaseUrl = 'https://mugeshbabu-main-backend.onrender.com';
  static const String _devBaseUrl = 'http://localhost:3000'; // Use this URL when running locally
  // static const String _devBaseUrl = 'https://mugeshbabu-main-backend.onrender.com'; // Use the same URL for development if not running locally
  static const Duration _timeout = Duration(seconds: 30);
  
  final Environment _environment;
  final http.Client _client;
  final Connectivity _connectivity;

  ApiService({
    Environment environment = Environment.production,
    http.Client? client,
    Connectivity? connectivity,
  }) : _environment = environment,
       _client = client ?? http.Client(),
       _connectivity = connectivity ?? Connectivity();

  String get _baseUrl {
    switch (_environment) {
      case Environment.development:
        return _devBaseUrl;
      case Environment.production:
        return _prodBaseUrl;
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'MugeshbabuApp/1.0.0',
  };

  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // If connectivity check fails, assume we have connection
      return true;
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    // Check network connectivity
    if (!await _checkConnectivity()) {
      throw NetworkException('No internet connection. Please check your network settings.');
    }

    try {
      // Build URL with query parameters
      final uri = Uri.parse('$_baseUrl$endpoint');
      final finalUri = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      // Prepare request
      late http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(finalUri, headers: _headers)
              .timeout(_timeout);
          break;
        case 'POST':
          response = await _client.post(
            finalUri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(_timeout);
          break;
        case 'PUT':
          response = await _client.put(
            finalUri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client.delete(finalUri, headers: _headers)
              .timeout(_timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Unable to connect to server. Please check your internet connection.');
    } on HttpException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: ${e.message}');
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      switch (response.statusCode) {
        case 200:
        case 201:
          return data;
        case 400:
          throw ApiException(
            data['message'] ?? 'Bad request',
            statusCode: response.statusCode,
            details: data['details']?.toString(),
          );
        case 401:
          throw ApiException(
            'Unauthorized access. Please login again.',
            statusCode: response.statusCode,
          );
        case 403:
          throw ApiException(
            'Access forbidden. You don\'t have permission to access this resource.',
            statusCode: response.statusCode,
          );
        case 404:
          throw ApiException(
            'Resource not found.',
            statusCode: response.statusCode,
          );
        case 429:
          throw ApiException(
            'Too many requests. Please try again later.',
            statusCode: response.statusCode,
          );
        case 500:
          throw ServerException(
            'Internal server error. Please try again later.',
            response.statusCode,
          );
        case 502:
        case 503:
        case 504:
          throw ServerException(
            'Server is temporarily unavailable. Please try again later.',
            response.statusCode,
          );
        default:
          throw ApiException(
            data['message'] ?? 'Unknown error occurred',
            statusCode: response.statusCode,
          );
      }
    } on FormatException {
      throw ApiException(
        'Invalid response format from server',
        statusCode: response.statusCode,
      );
    }
  }

  Future<ServicesResponse> getServices({
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }
      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }

      print('Making API request to: $_baseUrl/api/services');
      print('Query params: $queryParams');

      final response = await _makeRequest(
        'GET',
        '/api/services',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      print('API Response received: ${response.toString()}');
      
      return ServicesResponse.fromJson(response);
    } catch (e) {
      print('API Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch services: ${e.toString()}');
    }
  }

  Future<Service> getServiceById(String id) async {
    try {
      if (id.isEmpty) {
        throw ApiException('Service ID cannot be empty');
      }

      final response = await _makeRequest('GET', '/api/services/$id');
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final serviceData = data['service'] as Map<String, dynamic>? ?? response;
      
      return Service.fromJson(serviceData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch service details: ${e.toString()}');
    }
  }

  Future<List<String>> getServiceCategories() async {
    try {
      final response = await _makeRequest('GET', '/api/services/categories');
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final categories = data['categories'] as List<dynamic>? ?? [];
      
      return categories.map((category) => category.toString()).toList();
    } catch (e) {
      // If categories endpoint doesn't exist, return default categories
      return ['Internet', 'Cable', 'Snacks', 'Silver'];
    }
  }

  // Authentication Methods
  Future<AuthResponse> login(LoginRequest loginRequest) async {
    try {
      print('Making login request to: $_baseUrl/api/auth/login');
      print('Login data: ${loginRequest.toJson()}');

      final response = await _makeRequest(
        'POST',
        '/api/auth/login',
        body: loginRequest.toJson(),
      );

      print('Login response: ${response.toString()}');
      
      return AuthResponse.fromJson(response);
    } catch (e) {
      print('Login error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to login: ${e.toString()}');
    }
  }

  Future<AuthResponse> register(RegisterRequest registerRequest) async {
    try {
      print('Making register request to: $_baseUrl/api/auth/register');
      print('Register data: ${registerRequest.toJson()}');

      final response = await _makeRequest(
        'POST',
        '/api/auth/register',
        body: registerRequest.toJson(),
      );

      print('Register response: ${response.toString()}');
      
      return AuthResponse.fromJson(response);
    } catch (e) {
      print('Register error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to register: ${e.toString()}');
    }
  }

  // Quick login for development (using provided credentials)
  Future<AuthResponse> quickLogin() async {
    try {
      final loginRequest = LoginRequest(
        username: 'mugesharul1301@gmail.com',
        email: 'mugesharul1301@gmail.com',
        password: 'admin123',
      );

      return await login(loginRequest);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to quick login: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}

// Singleton instance for global access
class ApiServiceProvider {
  static ApiService? _instance;
  
  static ApiService get instance {
    _instance ??= ApiService(
      environment: Environment.production, // Always use production for now
    );
    return _instance!;
  }

  static void setInstance(ApiService service) {
    _instance = service;
  }

  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}
