import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jconnect/core/endpoint.dart';

class AuthRepository {
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<Map<String, dynamic>> sendPhoneOtp({required String phone}) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.sendPhoneOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send phone OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Send phone OTP error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required int otp,
    required String resetToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.verifyPhoneOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
          'resetToken': resetToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify phone OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Verify phone OTP error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String resetToken,
    required String emailOtp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.verifyEmailOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'resetToken': resetToken, 'emailOtp': emailOtp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify email OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Verify email OTP error: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}
