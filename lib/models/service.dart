class Service {
  final String id;
  final String name;
  final String category;
  final double amount;
  final String currency;
  final String billingCycle;
  final double averageRating;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.currency,
    required this.billingCycle,
    required this.averageRating,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      // Extract price information from nested price object
      final priceData = json['price'] as Map<String, dynamic>? ?? {};
      
      // Extract ratings information from nested ratings object
      final ratingsData = json['ratings'] as Map<String, dynamic>? ?? {};
      
      return Service(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Service',
        category: json['category']?.toString() ?? 'General',
        amount: _parseDouble(priceData['amount']),
        currency: priceData['currency']?.toString() ?? 'INR',
        billingCycle: priceData['billingCycle']?.toString() ?? 'monthly',
        averageRating: _parseDouble(ratingsData['average']),
        description: json['description']?.toString(),
        isActive: json['isAvailable'] == true || json['isActive'] == true,
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      throw FormatException('Failed to parse Service from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'currency': currency,
      'billingCycle': billingCycle,
      'averageRating': averageRating,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String get formattedPrice {
    return '$currency ${amount.toStringAsFixed(2)}/$billingCycle';
  }

  String get formattedRating {
    return averageRating.toStringAsFixed(1);
  }

  @override
  String toString() {
    return 'Service(id: $id, name: $name, category: $category, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ServicesResponse {
  final List<Service> services;
  final int total;
  final bool success;
  final String? message;

  ServicesResponse({
    required this.services,
    required this.total,
    required this.success,
    this.message,
  });

  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>? ?? {};
      final servicesJson = data['services'] as List<dynamic>? ?? [];
      
      final services = servicesJson
          .map((serviceJson) => Service.fromJson(serviceJson as Map<String, dynamic>))
          .toList();

      return ServicesResponse(
        services: services,
        total: services.length,
        success: json['success'] == true,
        message: json['message']?.toString(),
      );
    } catch (e) {
      throw FormatException('Failed to parse ServicesResponse from JSON: $e');
    }
  }
}
