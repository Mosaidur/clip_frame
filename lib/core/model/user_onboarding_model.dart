class UserOnboardingResponse {
  final int statusCode;
  final bool success;
  final String message;
  final OnboardingData? data;

  UserOnboardingResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory UserOnboardingResponse.fromJson(Map<String, dynamic> json) {
    return UserOnboardingResponse(
      statusCode: json['statusCode'] ?? 500,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? OnboardingData.fromJson(json['data']) : null,
    );
  }
}

class OnboardingData {
  final String id;
  final String businessType;
  final String businessDescription;
  final List<String> targetAudience;
  final List<String> preferredLanguages;
  final bool autoTranslateCaptions;
  final List<BrandColor> brandColors;
  final List<SocialHandle> socialHandles;
  final String logo;

  OnboardingData({
    required this.id,
    required this.businessType,
    required this.businessDescription,
    required this.targetAudience,
    required this.preferredLanguages,
    required this.autoTranslateCaptions,
    required this.brandColors,
    required this.socialHandles,
    required this.logo,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      id: json['_id'] ?? '',
      businessType: json['businessType'] ?? '',
      businessDescription: json['businessDescription'] ?? '',
      targetAudience: List<String>.from(json['targetAudience'] ?? []),
      preferredLanguages: List<String>.from(json['preferredLanguages'] ?? []),
      autoTranslateCaptions: json['autoTranslateCaptions'] ?? false,
      brandColors: (json['brandColors'] as List?)
              ?.map((e) => BrandColor.fromJson(e))
              .toList() ??
          [],
      socialHandles: (json['socialHandles'] as List?)
              ?.map((e) => SocialHandle.fromJson(e))
              .toList() ??
          [],
      logo: json['logo'] ?? '',
    );
  }
}

class BrandColor {
  final String name;
  final String value;
  final String id;

  BrandColor({
    required this.name,
    required this.value,
    required this.id,
  });

  factory BrandColor.fromJson(Map<String, dynamic> json) {
    return BrandColor(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class SocialHandle {
  final String platform;
  final String username;
  final String id;

  SocialHandle({
    required this.platform,
    required this.username,
    required this.id,
  });

  factory SocialHandle.fromJson(Map<String, dynamic> json) {
    return SocialHandle(
      platform: json['platform'] ?? '',
      username: json['username'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
