class UserResponse {
  final int statusCode;
  final bool success;
  final String message;
  final UserModel? data;

  UserResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      statusCode: json['statusCode'] ?? 500,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UserModel {
  final String sId; // _id from JSON
  final String name;
  final String email;
  final String phone;
  final String status;
  final bool verified;
  final bool subscribe;
  final String role;
  final String timezone;
  final String createdAt;
  final String updatedAt;
  final String id;
  final List<String> platforms;
  final String membership;
  final List<String> preferredLanguages;
  final String businessType;

  UserModel({
    required this.sId,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.verified,
    required this.subscribe,
    required this.role,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.platforms,
    required this.membership,
    required this.preferredLanguages,
    required this.businessType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      sId: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
      verified: json['verified'] ?? false,
      subscribe: json['subscribe'] ?? false,
      role: json['role'] ?? '',
      timezone: json['timezone'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      id: json['id'] ?? '',
      platforms: json['platforms'] != null
          ? List<String>.from(json['platforms'])
          : [],
      membership: json['membership'] ?? '',
      preferredLanguages: json['preferredLanguages'] != null
          ? List<String>.from(json['preferredLanguages'])
          : [],
      businessType: json['businessType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'verified': verified,
      'subscribe': subscribe,
      'role': role,
      'timezone': timezone,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'id': id,
      'platforms': platforms,
      'membership': membership,
      'preferredLanguages': preferredLanguages,
      'businessType': businessType,
    };
  }
}
