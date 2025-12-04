class Endpoint {
  static const String baseUrl = 'http://103.174.189.183:5050';

  // Auth endpoints
  static const String register = '$baseUrl/auth/register';
  static const String sendPhoneOtp = '$baseUrl/auth/register';
  static const String verifyPhoneOtp = '$baseUrl/auth/phone/verify-otp';
  static const String verifyEmailOtp = '$baseUrl/auth/signup-verify-otp';
  static const String login = '$baseUrl/auth/login';

  static const String recentArtis =
      "$baseUrl/users/artist?filter=recently-updated";
  static const String topRatedArtis =
      "$baseUrl/users/artist?filter=top-rated";
  static const String suggestedtArtis =
      "$baseUrl/users/artist?filter=suggested";
      static const String allArtists="$baseUrl/users/artist";
}
