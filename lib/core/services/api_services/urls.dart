class Urls {
  // base url
  static const String baseUrl = "http://10.10.7.50:5001";
  // static const String baseUrl = "http://10.0.2.2:5001"; // Reverted

  //auth api
  static const String logoutUrl = "$baseUrl/api/v1/auth/logout";
  static const String signupUrl = "$baseUrl/api/v1/auth/signup";
  static const String loginUrl = "$baseUrl/api/v1/auth/custom-login";
  static const String verifyEmailUrl = "$baseUrl/api/v1/auth/verify-account";
  static const String resendOTPUrl = "$baseUrl/api/v1/auth/resend-otp";
  static const String forgotPassword = "$baseUrl/api/v1/auth/forget-password";
  static const String resetPasswordUrl = "$baseUrl/api/v1/auth/reset-password";

  //useronboarding api
  static const String userOnboardingUrl =
      "$baseUrl/api/v1/useronboarding/branding";

  //user api
  static const String getUserProfileUrl = "$baseUrl/api/v1/user/profile";

  //scheduleing api
  static const String schedulingUrl =
      "$baseUrl/api/v1/content/my-contents?status=published";

  //content tamplate api
  static const String contentTemplateUrl =
      "$baseUrl/api/v1/contentTemplate?sortOrder=asc"; //all template api for reels.posts and stories
  static String createContentUrl(String contentId) =>
      "$baseUrl/api/v1/content/create/${contentId}";
  static String updateContentUrl(String id) => "$baseUrl/api/v1/content/$id";
  static String deleteContentUrl(String id) => "$baseUrl/api/v1/content/$id";
}
