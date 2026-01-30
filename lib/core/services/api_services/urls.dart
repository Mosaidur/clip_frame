class Urls{
  // base url 
  static const String baseUrl = "http://10.10.7.50:5001";

  //auth api
  static const String signupUrl = "$baseUrl/api/v1/auth/signup";
  static const String loginUrl = "$baseUrl/api/v1/auth/custom-login";
  static const String verifyEmailUrl = "$baseUrl/api/v1/auth/verify-account";
  static const String resendOTPUrl = "$baseUrl/api/v1/auth/resend-otp";
  static const String forgotPassword ="$baseUrl/api/v1/auth/forget-password";
  static const String resetPasswordUrl = "$baseUrl/api/v1/auth/reset-password";

  //useronboarding api
  static const String userOnboardingUrl =  "$baseUrl/api/v1/useronboarding";
  

}