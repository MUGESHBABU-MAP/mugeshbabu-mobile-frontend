class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, username: $username, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class LoginRequest {
  final String username;
  final String email;
  final String password;

  LoginRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String username;
  final String password;
  final String role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    this.role = 'customer',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>? ?? {};
      
      return AuthResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
        user: data['user'] != null ? User.fromJson(data['user']) : null,
        token: data['token']?.toString(),
      );
    } catch (e) {
      throw FormatException('Failed to parse AuthResponse from JSON: $e');
    }
  }

  bool get isSuccess => success && user != null;
}
